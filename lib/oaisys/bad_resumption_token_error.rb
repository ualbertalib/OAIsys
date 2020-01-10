class Oaisys::BadResumptionTokenError < Oaisys::PMHError

  attr_reader :parameters

  def initialize
    @parameters = {}
  end

  def error_code
    :badResumptionToken
  end

  def error_message
    I18n.t('error_messages.resumption_token_invalid')
  end

end
