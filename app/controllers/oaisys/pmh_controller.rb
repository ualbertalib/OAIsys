require_dependency 'oaisys/application_controller'

class Oaisys::PMHController < Oaisys::ApplicationController

  SUPPORTED_FORMATS = [
    { metadataPrefix: 'oai_dc',
      schema: 'http://www.openarchives.org/OAI/2.0/oai_dc.xsd',
      metadataNamespace: 'http://www.openarchives.org/OAI/2.0/oai_dc/' },
    { metadataPrefix: 'oai_etdms',
      schema: 'http://www.ndltd.org/standards/metadata/etdms/1-0/etdms.xsd',
      metadataNamespace: 'http://www.ndltd.org/standards/metadata/etdms/1.0/' },
    { metadataPrefix: 'ore',
      schema: 'http://www.kbcafe.com/rss/atom.xsd.xml',
      metadataNamespace: 'http://www.w3.org/2005/Atom' }
  ].freeze

  def bad_verb
    bad_verb = params.permit(:verb).to_h[:verb]
    raise Oaisys::BadVerbError.new(bad_verb: bad_verb)
  end

  def identify
    expect_no_args

    respond_to do |format|
      format.xml { render :identify }
    end
  end

  def list_sets
    expect_args exclusive: [:resumptionToken]
  end

  # TODO: Handle the identifier argument.
  def list_metadata_formats
    parameters = expect_args optional: [:identifier]

    respond_to do |format|
      format.xml do
        render :list_metadata_formats, locals: { supported_formats: SUPPORTED_FORMATS, parameters: parameters }
      end
    end
  end

  def list_records
    params = expect_args required: [:metadataPrefix], optional: [:from, :until, :set],
                         exclusive: [:resumptionToken]

    # Note the order here is critical: check whether or not we retrieved a page based on a resumption token
    # haven't been handed to the API, and if we were not, start the results on page 1
    resumption_token_provided = params[:page].present?
    params[:page] = 1 if params[:page].blank?

    query_params = query_params_from_api_params(params)

    items, total_count, cursor = public_items_for_metadata_format(**query_params)

    if items.out_of_range? && resumption_token_provided
      raise Oaisys::BadResumptionTokenError.new, I18n.t('error_messages.resumption_token_invalid')
    end
    raise Oaisys::NoRecordsMatchError.new(parameters: params.slice(:verb, :metadataPrefix)) if items.empty?

    resumption_token = resumption_token_from_params(parameters: params)
    params = params.slice(:verb, :resumptionToken) if resumption_token_provided

    respond_to do |format|
      format.xml do
        render :list_records, locals: { items: items, parameters: params.except(:page),
                                        metadata_format: params[:metadataPrefix],
                                        cursor: cursor, complete_list_size: total_count,
                                        resumption_token: resumption_token, last_page: items.last_page?,
                                        resumption_token_provided: resumption_token_provided }
      end
    end
  end

  # get_record is referring to the verb, not a getter.
  # rubocop:disable Naming/AccessorMethodName
  def get_record
    params = expect_args required: [:identifier, :metadataPrefix]

    metadata_format = params[:metadataPrefix]
    model = model_for_verb_format(verb: :get_record, format: metadata_format)
    obj = model.find(params[:identifier])

    raise IdDoesNotExistError.new(paramerters: params) if obj.blank?

    respond_to do |format|
      format.xml do
        render :get_record, locals: { item: obj, metadata_format: metadata_format }
      end
    end
  end
  # rubocop:enable Naming/AccessorMethodName

  # TODO: Handle from, until, and resumptionToken arguments.
  def list_identifiers
    params = expect_args required: [:metadataPrefix], optional: [:from, :until, :set],
                         exclusive: [:resumptionToken]

    # Note the order here is critical: check whether or not we retrieved a page based on a resumption token
    # haven been handed to the API, and if we were not, start the results on page 1
    resumption_token_provided = params[:page].present?
    params[:page] = 1 if params[:page].blank?

    query_params = query_params_from_api_params(params)

    identifiers_model, total_count, cursor = public_items_for_metadata_format(**query_params)
    identifiers = identifiers_model.pluck(:id, :record_created_at, :member_of_paths)

    if identifiers_model.out_of_range? && resumption_token_provided
      raise Oaisys::BadResumptionTokenError.new, I18n.t('error_messages.resumption_token_invalid')
    end
    raise Oaisys::NoRecordsMatchError.new(parameters: params.slice(:verb, :metadataPrefix)) if identifiers.empty?

    resumption_token = resumption_token_from_params(parameters: params)
    params = params.slice(:verb, :resumptionToken) if resumption_token_provided

    respond_to do |format|
      format.xml do
        render :list_identifiers, locals: { identifiers: identifiers, parameters: params.except(:page),
                                            cursor: cursor, complete_list_size: total_count,
                                            resumption_token: resumption_token, last_page: identifiers_model.last_page?,
                                            resumption_token_provided: resumption_token_provided }
      end
    end
  end

  private

  # Convention for calling expect_args without any arguments.
  def expect_no_args
    expect_args
  end

  def expect_args(required: [], optional: [], exclusive: [])
    # This makes the strong assumption that there's only one exclusive param per verb (which is the resumption token.)
    if params.key?(exclusive.first)
      params.require([:verb])
      parameters = params_from_resumption_token(resumption_token: params[exclusive.first])
      arguments = parameters.keys
      expected_verb_arguments = [:page] + required + optional + exclusive
      unexpected_arguments = (arguments - expected_verb_arguments).present?
      missing_required_arguments = (required - arguments).present?
      parameters[:page] = parameters[:page].to_i

      if unexpected_arguments || missing_required_arguments || parameters[:page] < 2
        raise Oaisys::BadResumptionTokenError.new, I18n.t('error_messages.resumption_token_invalid')
      end

      parameters.merge(verb: params[:verb])
    else
      params.require([:verb] + required)
      arguments = params.except('verb', 'controller', 'action').keys.map(&:to_sym)
      expected_verb_arguments = required + optional
      unexpected_arguments = (arguments - expected_verb_arguments).present?
      missing_required_arguments = (required - arguments).present?
      parameters = params.permit([:verb] + required + optional).to_h

      return parameters unless unexpected_arguments || missing_required_arguments

      raise Oaisys::BadArgumentError.new(parameters: parameters.slice(:verb))
    end
  end

  def model_for_verb_format(verb:, format:)
    model = ActsAsRdfable.known_classes_for(format: format).first
    raise Oaisys::CannotDisseminateError.new(parameters: { verb: verb, metadataPrefix: format }) if model.blank?

    model
  end

  def query_params_from_api_params(params)
    {}.tap do |query_params|
      query_params[:verb] = params[:verb]
      query_params[:format] = params[:metadataPrefix]
      query_params[:page] = params[:page]
      query_params[:restricted_to_set] = params[:set] if params[:set].present?
      query_params[:from_date] = params[:from] if params[:from].present?
      query_params[:until_date] = params[:until] if params[:until].present?
    end
  end

  def public_items_for_metadata_format(verb:, format:, page:, restricted_to_set: nil, from_date: nil, until_date: nil)
    model = model_for_verb_format(verb: verb, format: format)
    model = model.public_items
    model = model.public_items.belongs_to_path(restricted_to_set.tr(':', '/')) if restricted_to_set.present?
    model = model.created_on_or_after(from_date) if from_date.present?
    model = model.created_on_or_before(until_date) if until_date.present?
    items_per_request = Oaisys::Engine.config.items_per_request
    model = model.page(page).per(items_per_request)
    cursor = (page - 1) * items_per_request
    [model, model.total_count, cursor]
  end

  def resumption_token_from_params(parameters:)
    parameters[:page] = parameters[:page] + 1
    CGI.escape(parameters.except(:verb).to_query)
  end

  def params_from_resumption_token(resumption_token:)
    Rack::Utils.parse_query(CGI.unescape(resumption_token)).symbolize_keys
  end

end
