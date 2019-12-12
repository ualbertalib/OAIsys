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

    parameters[:page] = 1 if parameters[:page].blank?
    public_items_params = { verb: parameters[:verb], format: parameters[:metadataPrefix], page: parameters[:page].to_i }
    public_items_params = public_items_params.merge(restricted_to_set: parameters[:set]) if parameters[:set].present?
    public_items_params = public_items_params.merge(from_date: parameters[:from]) if parameters[:from].present?
    public_items_params = public_items_params.merge(until_date: parameters[:until]) if parameters[:until].present?

    identifiers_model, total_count, cursor = public_items_for_metadata_format(public_items_params)
    identifiers = identifiers_model.pluck(:id, :record_created_at, :member_of_paths)

    if identifiers_model.out_of_range? && parameters[:resumptionToken].present?
      raise Oaisys::BadResumptionTokenError.new, I18n.t('error_messages.resumption_token_invalid')
    end
    raise Oaisys::NoRecordsMatchError.new(parameters: parameters.slice(:verb, :metadataPrefix)) if identifiers.empty?

    parameters[:page] = parameters[:page].to_i + 1
    resumption_token = '&' + parameters.except(:verb, :resumptionToken).to_query
    resumption_token_provided = parameters[:resumptionToken].present?
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
      begin
        params.require([:page] + required)
        parameters = params.permit([:verb, :page] + required + optional + exclusive).to_h
        parameters[:resumptionToken] = '&' + parameters.except(:verb, :resumptionToken).to_query
        parameters
      rescue ActionController::UnpermittedParameters, ActionController::ParameterMissing
        raise Oaisys::BadResumptionTokenError.new, I18n.t('error_messages.resumption_token_invalid')
      end
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
