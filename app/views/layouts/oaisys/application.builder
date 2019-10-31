xml.instruct! :xml, version: '1.0'
xml.target! << '<OAI-PMH ' + Nokogiri::HTML.parse(content_for(:oai_pmh_header)) + '>'
xml.responseDate Time.now.utc.xmlschema
xml << yield
xml.target! << '</OAI-PMH>'
