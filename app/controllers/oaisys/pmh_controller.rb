require_dependency 'oaisys/application_controller'

class Oaisys::PMHController < Oaisys::ApplicationController
  before_action :before_action_method

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

  def before_action_method
    @short_header = false
  end

  def bad_verb; end

  def identify
    expect_no_args for_verb: :Identify
  end

  def list_sets
    expect_args for_verb: :ListSets, exclusive: [:resumptionToken]
  end

  # TODO: Handle the identifier argument.
  def list_metadata_formats
    expect_args for_verb: :ListMetadataFormats, optional: [:identifier]

    respond_to do |format|
      format.xml { render :list_metadata_formats, locals: { verb: :ListMetadataFormats, supported_formats: SUPPORTED_FORMATS } }
    end
  end

  def list_records
    expect_args for_verb: :ListRecords, required: [:metadataPrefix], optional: [:from, :until, :set],
                exclusive: [:resumptionToken]
  end

  # get_record is referring to the verb, not a getter.
  # rubocop:disable Naming/AccessorMethodName
  def get_record
    expect_args for_verb: :GetRecord, required: [:identifier, :metadataPrefix]
  end
  # rubocop:enable Naming/AccessorMethodName

  def list_identifiers
    expect_args for_verb: :ListIdentifiers, required: [:metadataPrefix], optional: [:from, :until, :set],
                exclusive: [:resumptionToken]
  end

  private

  def expect_args(for_verb:, required: [], optional: [], exclusive: [])
    arguments = params.except('verb', 'controller', 'action').keys.map(&:to_sym)
    expected_verb_arguments = required + optional + exclusive
    unexpected_arguments = (arguments - expected_verb_arguments).present?
    missing_required_arguments = (required - arguments).present?

    raise Oaisys::BadArgumentError.new(for_verb: for_verb) if unexpected_arguments || missing_required_arguments
  end

  # Conventional way of calling expect_args for a verb with no arguments.
  def expect_no_args(for_verb:)
    expect_args(for_verb: for_verb)
  end

end
