require 'test_helper'

class ListMetadataFormatsTest < ActionDispatch::IntegrationTest

  include Oaisys::Engine.routes.url_helpers

  setup do
    @routes = Oaisys::Engine.routes
  end

  def test_list_metadata_formats_xml
    get oaisys_path(verb: 'ListMetadataFormats'), headers: { 'Accept' => 'application/xml' }

    assert_list_metadata_formats_response
  end

  def test_list_metadata_formats_xml_post
    post oaisys_path(verb: 'ListMetadataFormats'), headers: { 'Content-Type' => 'application/x-www-form-urlencoded',
                                                              'Content-Length' => 82 }
    assert_list_metadata_formats_response
  end

  def assert_list_metadata_formats_response
    assert_response :success

    schema = Nokogiri::XML::Schema(File.open(file_fixture('OAI-PMH.xsd')))
    document = Nokogiri::XML(@response.body)
    assert_empty schema.validate(document)

    assert_select 'OAI-PMH' do
      assert_select 'responseDate'
      assert_select 'request', 'https://era.library.ualberta.ca/oai'
      assert_select 'ListMetadataFormats' do
        assert_select 'metadataFormat' do
          assert_select 'metadataPrefix', 'oai_dc'
          assert_select 'schema', 'http://www.openarchives.org/OAI/2.0/oai_dc.xsd'
          assert_select 'metadataNamespace', 'http://www.openarchives.org/OAI/2.0/oai_dc/'
        end
        assert_select 'metadataFormat' do
          assert_select 'metadataPrefix', 'oai_etdms'
          assert_select 'schema', 'http://www.ndltd.org/standards/metadata/etdms/1-0/etdms.xsd'
          assert_select 'metadataNamespace', 'http://www.ndltd.org/standards/metadata/etdms/1.0/'
        end
      end
    end
  end

end
