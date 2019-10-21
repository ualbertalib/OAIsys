require_dependency "oaisys/application_controller"

module Oaisys
  class PMHController < ApplicationController
    EXPECTED_ARGUMENTS = {
        identify: {
            required: %w(),
            optional: %w(),
            exclusive: %w()
        },
        list_sets: {
            required: %w(),
            optional: %w(),
            exclusive: %w(resumptionToken)
        },
        list_metadata_formats: {
            required: %w(),
            optional: %w(identifier),
            exclusive: %w()
        },
        list_records: {
            required: %w(metadataPrefix),
            optional: %w(from until set),
            exclusive: %w(resumptionToken)
        },
        get_record: {
            required: %w(identifier metadataPrefix),
            optional: %w(),
            exclusive: %w()
        },
        list_identifiers: {
            required: %w(metadataPrefix),
            optional: %w(from until set),
            exclusive: %w(resumptionToken)
        },
    }.freeze
    def bad_verb
    end

    def identify
      expected_ags(__method__)
    end

    def list_sets
      expected_ags(__method__)
    end

    def list_metadata_formats
      expected_ags(__method__)
    end

    def list_records
      expected_ags(__method__)
    end

    def get_record
      expected_ags(__method__)
    end

    def list_identifiers
      expected_ags(__method__)
    end

    private

    def expected_ags (verb)
      @verb = verb.to_s.camelize
      @error_code = 'badArgument'
      @error_message = 'The request includes illegal arguments or is missing required arguments.'
      @oai_pmh_header = {
          'xmlns': 'http://www.openarchives.org/OAI/2.0/',
          'xmlns:xsi': 'http://www.w3.org/2001/XMLSchema-instance',
          'xsi:schemaLocation': 'http://www.openarchives.org/OAI/2.0/ http://www.openarchives.org/OAI/2.0/OAI-PMH.xsd'}

      arguments = params.except('verb', 'controller', 'action').keys
      expected_verb_arguments = EXPECTED_ARGUMENTS[verb].map { |_, arr| arr }.flatten
      unexpected_arguments = !(arguments - expected_verb_arguments).empty?

      required_verb_arguments = EXPECTED_ARGUMENTS[verb][:required]
      missing_required_arguments = !(required_verb_arguments - arguments).empty?

      render template: 'responses/error_response.xml.builder' if (unexpected_arguments || missing_required_arguments)
    end
  end
end
