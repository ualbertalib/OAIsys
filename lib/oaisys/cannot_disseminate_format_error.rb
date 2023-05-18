class Oaisys::CannotDisseminateError < Oaisys::PMHError

  attr_reader :parameters

  def initialize(parameters:)
    super
    @parameters = parameters
  end

  def error_code
    :cannotDisseminateFormat
  end

  def error_message
    I18n.t('error_messages.unavailable_metadata_format')
  end

end
