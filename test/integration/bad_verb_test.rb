require 'test_helper'

class BadVerbTest < ActionDispatch::IntegrationTest

  include Oaisys::Engine.routes.url_helpers

  setup do
    @routes = Oaisys::Engine.routes
  end

  def test_bad_verb_xml
    get oaisys_path(verb: 'nastyVerb'), headers: { 'Accept' => 'application/xml' }

    assert_unknown_verb_response
  end

  def test_bad_verb_xml_post
    post oaisys_path(verb: 'nastyVerb'), headers: { 'Content-Type' => 'application/x-www-form-urlencoded', 'Content-Length' => 82 }

    assert_unknown_verb_response
  end

  def test_no_verb_xml
    get oaisys_path, headers: { 'Accept' => 'application/xml' }

    assert_no_verb_response
  end

  def test_no_verb_xml_post
    post oaisys_path, headers: { 'Content-Type' => 'application/x-www-form-urlencoded', 'Content-Length' => 82 }

    assert_no_verb_response
  end

  def assert_unknown_verb_response
    assert_response :success
    schema = Nokogiri::XML::Schema(File.open(file_fixture('OAI-PMH.xsd')))
    document = Nokogiri::XML(@response.body)
    assert_empty schema.validate(document)

    assert_select 'OAI-PMH' do
      assert_select 'responseDate'
      assert_select 'request'
      assert_select 'error', I18n.t('error_messages.unknown_verb')
    end
  end

  def assert_no_verb_response
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
