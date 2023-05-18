class Oaisys::BadVerbError < Oaisys::PMHError

  attr_reader :parameters

  # Pass nil for bad_verb if verb parameter wasn't given.
  def initialize(bad_verb:)
    super
    @parameters = {}
    @bad_verb = bad_verb
  end

  def error_code
    :badVerb
  end

  def error_message
    if @bad_verb.nil?
      I18n.t('error_messages.no_verb')
    else
      I18n.t('error_messages.unknown_verb', bad_verb: @bad_verb)
    end
  end

end
