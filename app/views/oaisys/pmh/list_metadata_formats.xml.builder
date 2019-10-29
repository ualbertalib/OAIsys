xml.request('https://era.library.ualberta.ca/oai', verb: verb)
xml.tag!('ListMetadataFormats') do
  supported_formats.each do |supported_format|
    xml.tag!('metadataFormat') do
      xml.metadataPrefix supported_format[:metadataPrefix]
      xml.schema supported_format[:schema]
      xml.metadataNamespace supported_format[:metadataNamespace]
    end
  end
end
