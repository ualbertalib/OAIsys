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
                            'xsi:schemaLocation': 'http://www.openarchives.org/OAI/2.0/ ' \
                                                  'http://www.openarchives.org/OAI/2.0/OAI-PMH.xsd ' \
                                                  'http://www.openarchives.org/OAI/2.0/oai-identifier ' \
                                                  'http://www.openarchives.org/OAI/2.0/oai-identifier.xsd ' \
                                                  'http://www.openarchives.org/OAI/2.0/oai_dc/ ' \
                                                  'http://www.openarchives.org/OAI/2.0/oai_dc.xsd ' \
                                                  'http://www.ndltd.org/standards/metadata/etdms/1.0/ ' \
                                                  'http://www.ndltd.org/standards/metadata/etdms/1-0/etdms.xsd ' \
                                                  'http://www.w3.org/2005/Atom')

xml.request('https://era.library.ualberta.ca/oai', verb: 'Identify')
xml.Identify do
  xml.repositoryName 'ERA: Education and Research Archive'
  xml.baseURL 'https://era.library.ualberta.ca/oai'
  xml.protocolVersion '2.0'
  xml.adminEmail 'eraadmi@ualberta.ca'
  xml.earliestDatestamp '2018-06-22T13:06:50Z'
  xml.deletedRecord 'no'
  xml.granularity 'YYYY-MM-DDThh:mm:ssZ'
  xml.description do
    xml.tag!('oai-id:oai-identifier') do
      xml.tag!('oai-id:scheme', 'oai')
      xml.tag!('oai-id:repositoryIdentifier', 'era.library.ualberta.ca')
      xml.tag!('oai-id:delimiter', ':')
      xml.tag!('oai-id:sampleIdentifier', 'oai:era.library.ualberta.ca:1d7047d8-f164-45bb-b62c-ae6045eb0c42')
    end
  end
end
