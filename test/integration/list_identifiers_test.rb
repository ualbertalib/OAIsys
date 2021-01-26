require 'test_helper'

class ListIdentifiersTest < ActionDispatch::IntegrationTest

  include Oaisys::Engine.routes.url_helpers

  setup do
    @routes = Oaisys::Engine.routes
  end

  def test_cannot_disseminate_format_xml
    get oaisys_path(verb: 'ListIdentifiers', metadataPrefix: 'nasty'), headers: { 'Accept' => 'application/xml' }

    assert_unavailable_metadata_format_response
  end

  def test_cannot_disseminate_format_xml_post
    post oaisys_path(verb: 'ListIdentifiers', metadataPrefix: 'nasty'),
         headers: { 'Content-Type' => 'application/x-www-form-urlencoded', 'Content-Length' => 82 }

    assert_unavailable_metadata_format_response
  end

  def assert_unavailable_metadata_format_response
    assert_response :success

    schema = Nokogiri::XML::Schema(File.open(file_fixture('OAI-PMH.xsd')))
    document = Nokogiri::XML(@response.body)
    assert_empty schema.validate(document)

    assert_select 'OAI-PMH' do
      assert_select 'responseDate'
      assert_select 'request'
      assert_select 'error', I18n.t('error_messages.unavailable_metadata_format')
    end
  end

end
