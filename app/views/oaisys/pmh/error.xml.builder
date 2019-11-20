if error_code == :badArgument
  xml.push_deferred_attribute('xmlns': 'http://www.openarchives.org/OAI/2.0/',
                              'xmlns:xsi': 'http://www.w3.org/2001/XMLSchema-instance',
                              'xsi:schemaLocation': 'http://www.openarchives.org/OAI/2.0/ '\
                              'http://www.openarchives.org/OAI/2.0/OAI-PMH.xsd')
else
  xml.push_deferred_attribute('xmlns:dc': 'http://purl.org/dc/elements/1.1/',
                              'xmlns:oai-id': 'http://www.openarchives.org/OAI/2.0/oai-identifier',
                              'xmlns': 'http://www.openarchives.org/OAI/2.0/',
                              'xmlns:etd_ms': 'http://www.ndltd.org/standards/metadata/etdms/1.0/',
                              'xmlns:atom': 'http://www.w3.org/2005/Atom',
                              'xmlns:rdfs': 'http://www.w3.org/2000/01/rdf-schema#',
                              'xmlns:rdf': 'http://www.w3.org/1999/02/22-rdf-syntax-ns#',
                              'xmlns:dcterms': 'http://purl.org/dc/terms/',
                              'xmlns:oreatom': 'http://www.openarchives.org/ore/atom/',
                              'xmlns:oai_dc': 'http://www.openarchives.org/OAI/2.0/oai_dc/',
                              'xmlns:xsi': 'http://www.w3.org/2001/XMLSchema-instance',
                              'xsi:schemaLocation': 'http://www.openarchives.org/OAI/2.0/ '\
                              'http://www.openarchives.org/OAI/2.0/OAI-PMH.xsd '\
                              'http://www.openarchives.org/OAI/2.0/oai-identifier '\
                              'http://www.openarchives.org/OAI/2.0/oai-identifier.xsd '\
                              'http://www.openarchives.org/OAI/2.0/oai_dc/ '\
                              'http://www.openarchives.org/OAI/2.0/oai_dc.xsd '\
                              'http://www.ndltd.org/standards/metadata/etdms/1.0/ '\
                              'http://www.ndltd.org/standards/metadata/etdms/1-0/etdms.xsd '\
                              'http://www.w3.org/2005/Atom')
end

xml.tag!('request', parameters)
xml.error(error_message, code: error_code)
