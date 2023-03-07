class Oaisys::BadArgumentError < Oaisys::PMHError

  attr_reader :parameters

  def initialize(parameters:)
    super
    @parameters = parameters
  end

  def error_code
    :badArgument
  end

  def error_message
    I18n.t('error_messages.illegal_or_missing_arguments')
  end

end
