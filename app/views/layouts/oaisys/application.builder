xml.instruct! :xml, version: '1.0'
xml.tag!('OAI-PMH', xml.deferred_attributes) do
  xml.responseDate Time.now.utc.xmlschema
  xml << yield
end
