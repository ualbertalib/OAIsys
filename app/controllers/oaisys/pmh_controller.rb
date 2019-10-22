require_dependency "oaisys/application_controller"

module Oaisys
  class PMHController < ApplicationController
    layout 'oai_pmh_response.xml.builder'

    def bad_verb
    end

    def identify
      expect_args(__method__, required: %i(), optional: %i(), exclusive: %i())
    end

    def list_sets
      expect_args(__method__, required: %i(), optional: %i(), exclusive: %i(resumptionToken))
    end

    def list_metadata_formats
      expect_args(__method__, required: %i(), optional: %i(identifier), exclusive: %i())
    end

    def list_records
      expect_args(__method__, required: %i(metadataPrefix), optional: %i(from until set), exclusive: %i(resumptionToken))
    end

    def get_record
      expect_args(__method__, required: %i(identifier metadataPrefix), optional: %i(), exclusive: %i())
    end

    def list_identifiers
      expect_args(__method__, required: %i(metadataPrefix), optional: %i(from until set), exclusive: %i(resumptionToken))
    end

    private

    def expect_args (verb, required:, optional:, exclusive:)
      arguments = params.except('verb', 'controller', 'action').keys.map(&:to_sym)
      expected_verb_arguments = required + optional + exclusive
      unexpected_arguments = (arguments - expected_verb_arguments).present?
      missing_required_arguments = (required - arguments).present?

      if unexpected_arguments || missing_required_arguments
        verb = verb.to_s.camelize
        error_code = 'badArgument'
        error_message = t('error_messages.illegal_or_missing_arguments')
        render template: 'responses/error_response.xml.builder', locals: { verb: verb, error_code: error_code, error_message: error_message }
      end
    end
  end
end
