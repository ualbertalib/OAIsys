require_dependency "oaisys/application_controller"

module Oaisys
  class PMHController < ApplicationController
    def bad_verb
    end

    def identify
      expect_no_args for_verb: :Identify
    end

    def list_sets
      expect_args for_verb: :ListSets, exclusive: [:resumptionToken]
    end

    def list_metadata_formats
      expect_args for_verb: :ListMetadataFormats, optional: [:identifier]
    end

    def list_records
      expect_args for_verb: :ListRecords, required: [:metadataPrefix], optional: [:from, :until, :set], exclusive: [:resumptionToken]
    end

    def get_record
      expect_args for_verb: :GetRecord, required: [:identifier, :metadataPrefix]
    end

    def list_identifiers
      expect_args for_verb: :ListIdentifiers, required: [:metadataPrefix], optional: [:from, :until, :set], exclusive: [:resumptionToken]
    end

    private

    def expect_args (for_verb:, required: [], optional: [], exclusive: [])
      arguments = params.except('verb', 'controller', 'action').keys.map(&:to_sym)
      expected_verb_arguments = required + optional + exclusive
      unexpected_arguments = (arguments - expected_verb_arguments).present?
      missing_required_arguments = (required - arguments).present?

      if unexpected_arguments || missing_required_arguments
        raise BadArgumentError.new(for_verb: for_verb)
      end
    end

    # Conventional way of calling expect_args for a verb with no arguments.
    def expect_no_args(for_verb:)
      expect_args(for_verb: for_verb)
    end
  end
end
