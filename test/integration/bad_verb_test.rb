require 'test_helper'

class BadVerbTest < ActionDispatch::IntegrationTest

  include Oaisys::Engine.routes.url_helpers

  setup do
    @routes = Oaisys::Engine.routes
    # Set an action on unpermitted parameters to raise an exception, used to validate parameters.
    ActionController::Parameters.action_on_unpermitted_parameters = :raise
  end

  def test_bad_verb_xml
    get oaisys_path(verb: 'nastyVerb'), headers: { 'Accept' => 'application/xml' }
    assert_response :success

    schema = Nokogiri::XML::Schema(File.open(file_fixture('OAI-PMH.xsd')))
    document = Nokogiri::XML(@response.body)
    assert_empty schema.validate(document)

    assert_select 'OAI-PMH' do
      assert_select 'responseDate'
      assert_select 'request'
      assert_select 'error', I18n.t('error_messages.unknown_verb', bad_verb: 'nastyVerb')
    end
  end

  def test_no_verb_xml
    get oaisys_path, headers: { 'Accept' => 'application/xml' }
    assert_response :success

    schema = Nokogiri::XML::Schema(File.open(file_fixture('OAI-PMH.xsd')))
    document = Nokogiri::XML(@response.body)
    assert_empty schema.validate(document)

    assert_select 'OAI-PMH' do
      assert_select 'responseDate'
      assert_select 'request'
      assert_select 'error', I18n.t('error_messages.no_verb')
    end
  end

end
