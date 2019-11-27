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

    metadata_prefix = params[:metadataPrefix]
    if metadata_prefix == 'oai_dc'
      results = Oaisys::Engine.config.oai_dc_model.public_items
    elsif metadata_prefix == 'oai_etdms'
      results = Oaisys::Engine.config.oai_etdms_model.public_items
    else
      raise Oaisys::CannotDisseminateFormatError.new(parameters: @parameters.slice(:verb, :metadataPrefix))
    end
    results = results.belongs_to_set(params[:set].tr(':', '/')) if params[:set].present?
    raise Oaisys::NoRecordsMatchError.new(parameters: @parameters.slice(:verb, :metadataPrefix)) if results.empty?

    respond_to do |format|
      format.xml do
        render :list_identifiers, locals: { results: results, parameters: @parameters }
      end
    end
  end

  private

  def expect_args(required: [], optional: [], exclusive: [])
    arguments = params.except('verb', 'controller', 'action').keys.map(&:to_sym)
    expected_verb_arguments = required + optional + exclusive
    unexpected_arguments = (arguments - expected_verb_arguments).present?
    missing_required_arguments = (required - arguments).present?

    @parameters = params.permit([:verb] + required + optional + exclusive).to_h
    return unless unexpected_arguments || missing_required_arguments

    raise Oaisys::BadArgumentError.new(parameters: @parameters.slice(:verb))
  end

end
