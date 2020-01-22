module Oaisys::ListIdentifiersHelper
  def resumption_token(xml_object:, complete_list_size:, cursor:, resumption_token:, last_page:,
                       resumption_token_provided:)
    return unless !last_page || resumption_token_provided

    if last_page
      xml_object.tag!('resumptionToken', completeListSize: complete_list_size, cursor: cursor)
    else
      expiration_date = (Time.current + 72.hours).utc.xmlschema
      xml_object.tag!('resumptionToken', { expirationDate: expiration_date,
                                           completeListSize: complete_list_size, cursor: cursor }, resumption_token)
    end
  end
end
