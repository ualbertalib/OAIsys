require 'test_helper'

class NavigationTest < ActionDispatch::IntegrationTest

  include Oaisys::Engine.routes.url_helpers

  setup do
    @routes = Oaisys::Engine.routes
  end

  def test_unexpected_args_xml
    get oaisys_path + '?verb=ListMetadataFormats&nastParam=nasty', headers: { "Accept" => "application/xml" }

    schema = Nokogiri::XML::Schema(File.open(file_fixture('OAI-PMH.xsd')))
    document = Nokogiri::XML(@response.body)
    assert_empty schema.validate(document)

    assert_select 'OAI-PMH' do
      assert_select 'responseDate'
      assert_select 'request'
      assert_select 'error', I18n.t('error_messages.illegal_or_missing_arguments')
    end
  end
end
