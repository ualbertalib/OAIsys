xml.push_deferred_attribute(error_header(error_code: error_code))

xml.tag!('request', parameters)
xml.error(error_message, code: error_code)
