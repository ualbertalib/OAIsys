module Oaisys::ListIdentifiersHelper
  def resumption_token(xml_object:, complete_list_size:, cursor:, resumption_token:, last_page:,
                       resumption_token_provided:)
    return unless !last_page || resumption_token_provided

    if last_page
      xml_object.tag!('resumptionToken', completeListSize: complete_list_size, cursor:)
    else
      expiration_date = (Time.current + Oaisys::Engine.config.resumption_token_expiry).utc.xmlschema
      xml_object.tag!('resumptionToken', { expirationDate: expiration_date,
                                           completeListSize: complete_list_size, cursor: }, resumption_token)
    end
  end
end
