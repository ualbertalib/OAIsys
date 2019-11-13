require 'test_helper'

class ListMetadataFormatsTest < ActionDispatch::IntegrationTest

  include Oaisys::Engine.routes.url_helpers

  setup do
    @routes = Oaisys::Engine.routes
  end

  def test_list_metadata_formats_xml
    get oaisys_path + '?verb=ListMetadataFormats', headers: { 'Accept' => 'application/xml' }
    assert_response :success

    schema = Nokogiri::XML::Schema(File.open(file_fixture('OAI-PMH.xsd')))
    document = Nokogiri::XML(@response.body)
    assert_empty schema.validate(document)

    assert_select 'OAI-PMH' do
      assert_select 'responseDate'
      assert_select 'request'
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
        assert_select 'metadataFormat' do
          assert_select 'metadataPrefix', 'ore'
          assert_select 'schema', 'http://www.kbcafe.com/rss/atom.xsd.xml'
          assert_select 'metadataNamespace', 'http://www.w3.org/2005/Atom'
        end
      end
    end
  end

end
