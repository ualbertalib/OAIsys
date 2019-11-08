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

    supported_formats = Oaisys::PMHController::SUPPORTED_FORMATS
    assert_select 'OAI-PMH' do
      assert_select 'responseDate'
      assert_select 'request'
      assert_select 'ListMetadataFormats' do
        supported_formats.each do |supported_format|
          assert_select 'metadataFormat' do
            assert_select 'metadataPrefix', supported_format[:metadataPrefix]
            assert_select 'schema', supported_format[:schema]
            assert_select 'metadataNamespace', supported_format[:metadataNamespace]
          end
        end
      end
    end
  end

end
