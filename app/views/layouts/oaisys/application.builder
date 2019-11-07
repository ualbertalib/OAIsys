xml_body = Builder::XmlMarkup.new
xml.instruct! :xml, version: '1.0'
xml << deferred_param_tagging('OAI-PMH') do
  xml_body.responseDate Time.now.utc.xmlschema
  xml_body << yield
end
