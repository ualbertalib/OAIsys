xml.push_deferred_attribute(error_header(error_code:))

xml.tag!('request', parameters, 'https://era.library.ualberta.ca/oai')
xml.error(error_message, code: error_code)
