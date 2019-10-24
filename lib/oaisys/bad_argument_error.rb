module Oaisys
  class BadArgumentError < PMHError
    attr_reader :for_verb

    def initialize(for_verb:)
      @for_verb = for_verb
    end

    def error_code
      :badArgument
    end

    def error_message
      I18n.t('error_messages.illegal_or_missing_arguments')
    end
  end
end