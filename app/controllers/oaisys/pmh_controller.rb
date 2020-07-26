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
    parameters = expect_args exclusive: [:resumptionToken]

    resumption_token_provided = parameters[:resumptionToken].present?
    parameters[:page] = 1 if parameters[:page].blank?
    sets_model, total_count, cursor = sets_on_page(page: parameters[:page])

    parameters[:item_count] = total_count if parameters[:item_count].nil?

    check_resumption_token(sets_model, resumption_token_provided, total_count, parameters)

    top_level_sets = Oaisys::Engine.config.top_level_sets_model.pluck(:id, :title)
    sets = sets_model.pluck(:community_id, :id, :title, :description)

    sets.map! do |top_level_sets_id, id, title, description|
      top_level_set = top_level_sets.find { |a| a[0] == top_level_sets_id }[1]
      full_set_id = top_level_sets_id + ':' + id
      full_set_name = top_level_set + ' / ' + title
      [full_set_id, full_set_name, description]
    end
    resumption_token = resumption_token_from_params(parameters: parameters)
    parameters = parameters.slice(:verb, :resumptionToken) if resumption_token_provided

    respond_to do |format|
      format.xml do
        render :list_sets, locals: { sets: sets, parameters: parameters.except(:page, :item_count),
                                     cursor: cursor, complete_list_size: total_count,
                                     resumption_token: resumption_token, last_page: sets_model.last_page?,
                                     resumption_token_provided: resumption_token_provided }
      end
    end
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
    params[:item_count] = total_count if params[:item_count].nil?

    raise Oaisys::NoRecordsMatchError.new(parameters: params.slice(:verb, :metadataPrefix)) if items.empty?

    check_resumption_token(items, resumption_token_provided, total_count, params)

    resumption_token = resumption_token_from_params(parameters: params)
    metadata_format = params[:metadataPrefix]
    params = params.slice(:verb, :resumptionToken) if resumption_token_provided

    respond_to do |format|
      format.xml do
        render :list_records, locals: { items: items, parameters: params.except(:page, :item_count),
                                        metadata_format: metadata_format,
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

  def list_identifiers
    params = expect_args required: [:metadataPrefix], optional: [:from, :until, :set],
                         exclusive: [:resumptionToken]

    # Note the order here is critical: check whether or not we retrieved a page based on a resumption token
    # haven't been handed to the API, and if we were not, start the results on page 1
    resumption_token_provided = params[:page].present?
    params[:page] = 1 if params[:page].blank?

    query_params = query_params_from_api_params(params)

    identifiers_model, total_count, cursor = public_items_for_metadata_format(**query_params)
    identifiers = identifiers_model.pluck(:id, :updated_at, :member_of_paths)
    params[:item_count] = total_count if params[:item_count].nil?

    raise Oaisys::NoRecordsMatchError.new(parameters: params.slice(:verb, :metadataPrefix)) if identifiers.empty?

    check_resumption_token(identifiers_model, resumption_token_provided, total_count, params)

    resumption_token = resumption_token_from_params(parameters: params)
    params = params.slice(:verb, :resumptionToken) if resumption_token_provided
    respond_to do |format|
      format.xml do
        render :list_identifiers, locals: { identifiers: identifiers, parameters: params.except(:page, :item_count),
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
      parameters = params_from_resumption_token(resumption_token: params[exclusive.first], verb: params[:verb])

      # Token doesn't exist in Redis.
      raise Oaisys::BadResumptionTokenError.new, I18n.t('error_messages.resumption_token_invalid') if parameters.nil?

      arguments = parameters.keys
      expected_verb_arguments = [:page, :item_count] + required + optional + exclusive
      unexpected_arguments = (arguments - expected_verb_arguments).present?
      missing_required_arguments = (required - arguments).present?
      parameters[:item_count] = parameters[:item_count].to_i
      parameters[:page] = parameters[:page].to_i
      parameters[:resumptionToken] = parameters[:page].to_i
      if unexpected_arguments || missing_required_arguments || parameters[:page] < 2
        raise Oaisys::BadResumptionTokenError.new, I18n.t('error_messages.resumption_token_invalid')
      end

      parameters.merge(verb: params[:verb], resumptionToken: params[:resumptionToken])
    else
      params.require([:verb] + required)
      arguments = params.except('verb', 'controller', 'action', 'subdomain').keys.map(&:to_sym)
      expected_verb_arguments = required + optional
      unexpected_arguments = (arguments - expected_verb_arguments).present?
      missing_required_arguments = (required - arguments).present?
      parameters = params.permit([:verb, :subdomain] + required + optional).except(:subdomain).to_h

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

    model = model.updated_on_or_after(from_date) if from_date.present?
    model = model.updated_on_or_before(until_date) if until_date.present?

    items_per_request = Oaisys::Engine.config.items_per_request
    model = model.page(page).per(items_per_request)
    cursor = (page - 1) * items_per_request
    [model, model.total_count, cursor]
  end

  def sets_on_page(page:)
    items_per_request = Oaisys::Engine.config.items_per_request
    model = Oaisys::Engine.config.set_model

    model = model.page(page).per(items_per_request)
    cursor = (page - 1) * items_per_request
    [model, model.total_count, cursor]
  end

  def expire_token(resumption_token:, verb:)
    Oaisys::Engine.config.redis.expire_token(resumption_token: resumption_token, verb: verb, identifier: user_agent)
  end

  def resumption_token_from_params(parameters:)
    parameters[:page] = parameters[:page] + 1
    Oaisys::Engine.config.redis.create_token(parameters: parameters.except(:verb, :resumptionToken),
                                             verb: parameters[:verb], identifier: user_agent)
  end

  def params_from_resumption_token(resumption_token:, verb:)
    Oaisys::Engine.config.redis.get_parameters(resumption_token: resumption_token, verb: verb, identifier: user_agent)
  end

  def user_agent
    user_agent = request.user_agent

    return request.remote_ip if user_agent.blank?

    user_agent
  end

  def check_resumption_token(model, resumption_token_provided, total_count, parameters)
    if model.out_of_range? && resumption_token_provided
      raise Oaisys::BadResumptionTokenError.new, I18n.t('error_messages.resumption_token_invalid')
    end

    return unless resumption_token_provided && (parameters[:item_count] != total_count)

    # Results have changed, expire token
    expire_token(resumption_token: parameters[:resumptionToken], verb: parameters[:verb])
    raise Oaisys::BadResumptionTokenError.new, I18n.t('error_messages.resumption_token_invalid')
  end

end
