module Oaisys::SetDescriptionHelper
  def set_description(xml:, description:)
    return if description.blank?

    xml.setDescription do
      xml.tag!('oai_dc:dc', 'xmlns:oai_dc': 'http://www.openarchives.org/OAI/2.0/oai_dc/',
                            'xmlns:dc': 'http://purl.org/dc/elements/1.1/',
                            'xmlns:xsi': 'http://www.w3.org/2001/XMLSchema-instance',
                            'xsi:schemaLocation': 'http://www.openarchives.org/OAI/2.0/oai_dc/ ' \
                                                  'http://www.openarchives.org/OAI/2.0/oai_dc.xsd') do
        xml.tag!('dc:description', description)
      end
    end
  end
end
