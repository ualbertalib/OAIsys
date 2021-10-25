class Oaisys::NoMetadataFormatsError < Oaisys::PMHError

  attr_reader :parameters

  def initialize(parameters:)
    super
    @parameters = parameters
  end

  def error_code
    :noMetadataFormats
  end

  def error_message
    I18n.t('error_messages.no_metadata_formats')
  end

end
