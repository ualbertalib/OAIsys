xml.push_deferred_attribute('xmlns': 'http://www.openarchives.org/OAI/2.0/',
                            'xmlns:xsi': 'http://www.w3.org/2001/XMLSchema-instance',
                            'xsi:schemaLocation': 'http://www.openarchives.org/OAI/2.0/ '\
                            'http://www.openarchives.org/OAI/2.0/OAI-PMH.xsd')

xml.request(verb: verb)
xml.error(error_message, code: error_code)
