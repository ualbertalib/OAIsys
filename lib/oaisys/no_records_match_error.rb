class Oaisys::NoRecordsMatchError < Oaisys::PMHError

  attr_reader :parameters

  def initialize(parameters:)
    super
    @parameters = parameters
  end

  def error_code
    :noRecordsMatch
  end

  def error_message
    I18n.t('error_messages.no_record_found')
  end

end
