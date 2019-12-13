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
  ITEMS_PER_REQUEST = 150

  def bad_verb; end

  def identify
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
    expect_args required: [:metadataPrefix], optional: [:from, :until, :set], exclusive: [:resumptionToken]
  end

  # get_record is referring to the verb, not a getter.
  # rubocop:disable Naming/AccessorMethodName
  def get_record
    expect_args required: [:identifier, :metadataPrefix]
  end
  # rubocop:enable Naming/AccessorMethodName

  # TODO: Handle from, until, and resumptionToken arguments.
  def list_identifiers
    parameters = expect_args required: [:metadataPrefix], optional: [:from, :until, :set],
                             exclusive: [:resumptionToken]

    public_items_params = { verb: parameters[:verb], format: parameters[:metadataPrefix],
                            page: parameters[:page].blank? ? 1 : parameters[:page].to_i }
    public_items_params = public_items_params.merge(restricted_to_set: parameters[:set]) if parameters[:set].present?
    public_items_params = public_items_params.merge(from_date: parameters[:from]) if parameters[:from].present?
    public_items_params = public_items_params.merge(until_date: parameters[:until]) if parameters[:until].present?

    identifiers_model, total_count, cursor = public_items_for_metadata_format(public_items_params)
    identifiers = identifiers_model.pluck(:id, :record_created_at, :member_of_paths)
    if identifiers_model.out_of_range? && parameters[:page].present?
      raise Oaisys::BadResumptionTokenError.new, I18n.t('error_messages.resumption_token_invalid')
    end
    raise Oaisys::NoRecordsMatchError.new(parameters: parameters.slice(:verb, :metadataPrefix)) if identifiers.empty?

    resumption_token_provided = parameters[:page].present?
    parameters[:page] = parameters[:page].blank? ? 2 : parameters[:page].to_i + 1
    resumption_token = CGI.escape(parameters.except(:verb).to_query)
    parameters = parameters.slice(:verb, :resumptionToken) if resumption_token_provided
    respond_to do |format|
      format.xml do
        render :list_identifiers, locals: { identifiers: identifiers, parameters: parameters.except(:page),
                                            cursor: cursor, complete_list_size: total_count,
                                            resumption_token: resumption_token, last_page: identifiers_model.last_page?,
                                            resumption_token_provided: resumption_token_provided }
      end
    end
  end

  private

  def expect_args(required: [], optional: [], exclusive: [])
    # This makes the strong assumption that there's only one exclusive param per verb
    if params.key?(exclusive.first)
      params.require([:verb])
      parameters = Rack::Utils.parse_query(CGI.unescape(params[exclusive.first])).symbolize_keys
      arguments = parameters.keys
      expected_verb_arguments = [:page] + required + optional + exclusive
      unexpected_arguments = (arguments - expected_verb_arguments).present?
      missing_required_arguments = (required - arguments).present?

      if unexpected_arguments || missing_required_arguments
        raise Oaisys::BadResumptionTokenError.new, I18n.t('error_messages.resumption_token_invalid')
      end

      parameters.merge(verb: params[:verb])
    else
      params.require([:verb] + required)
      params.permit([:verb] + required + optional + exclusive).to_h
    end
  end

  def public_items_for_metadata_format(verb:, format:, page:, restricted_to_set: nil, from_date: nil, until_date: nil)
    model = case format
            when 'oai_dc'
              Oaisys::Engine.config.oai_dc_model
            when 'oai_etdms'
              Oaisys::Engine.config.oai_etdms_model
            else
              raise Oaisys::CannotDisseminateFormatError.new(parameters: { verb: verb, metadataPrefix: format })
            end
    model = model.public_items
    model = model.public_items.belongs_to_path(restricted_to_set.tr(':', '/')) if restricted_to_set.present?
    model = model.created_on_or_after(from_date) if from_date.present?
    model = model.created_on_or_before(until_date) if until_date.present?

    model = model.page(page).per(ITEMS_PER_REQUEST)
    cursor = (page - 1) * ITEMS_PER_REQUEST
    [model, model.total_count, cursor]
  end

end
