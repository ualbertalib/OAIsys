class Oaisys::CannotDisseminateFormatError < Oaisys::PMHError

  attr_reader :parameters

  def initialize(parameters:)
    @parameters = parameters
  end

  def error_code
    :cannotDisseminateFormat
  end

  def error_message
    I18n.t('error_messages.unavailable_metadata_format')
  end

end
