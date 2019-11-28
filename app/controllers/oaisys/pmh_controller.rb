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
    expect_args optional: [:identifier]

    respond_to do |format|
      format.xml do
        render :list_metadata_formats, locals: { supported_formats: SUPPORTED_FORMATS, parameters: @parameters }
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
    expect_args required: [:metadataPrefix], optional: [:from, :until, :set], exclusive: [:resumptionToken]

    results = results_from_metadata_prefix
    results = results.belongs_to_path(params[:set].tr(':', '/')) if params[:set].present?
    raise Oaisys::NoRecordsMatchError.new(parameters: @parameters.slice(:verb, :metadataPrefix)) if results.empty?

    respond_to do |format|
      format.xml do
        render :list_identifiers, locals: { results: results, parameters: @parameters }
      end
    end
  end

  private

  def expect_args(required: [], optional: [], exclusive: [])
    ActionController::Parameters.action_on_unpermitted_parameters = :raise
    params.require([:verb] + required)
    @parameters = params.permit([:verb] + required + optional + exclusive).to_h
  end

  def results_from_metadata_prefix
    model = case params[:metadataPrefix]
            when 'oai_dc'
              Oaisys::Engine.config.oai_dc_model
            when 'oai_etdms'
              Oaisys::Engine.config.oai_etdms_model
            else
              raise Oaisys::CannotDisseminateFormatError.new(parameters: @parameters.slice(:verb, :metadataPrefix))
            end
    model.public_items
  end

end
