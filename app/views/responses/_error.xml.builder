xml.instruct! :xml, version: '1.0'
xml.tag!('OAI-PMH', oai_pmh_header) do
  xml.responseDate Time.now.utc.xmlschema
  xml.request({verb: verb})
  xml.error(error_message, {code: error_code})
end