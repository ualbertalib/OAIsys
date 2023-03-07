class Oaisys::IdDoesNotExistError < Oaisys::PMHError

  attr_reader :parameters

  def initialize(parameters:)
    super
    @parameters = parameters
  end

  def error_code
    :idDoesNotExist
  end

  def error_message
    I18n.t('error_messages.id_does_not_exist')
  end

end
