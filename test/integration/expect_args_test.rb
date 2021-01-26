require 'test_helper'

class ExpectArgsTest < ActionDispatch::IntegrationTest

  include Oaisys::Engine.routes.url_helpers

  setup do
    @routes = Oaisys::Engine.routes
  end

  def test_unexpected_arg_xml
    get oaisys_path(verb: 'ListMetadataFormats', nastyParam: 'nasty'), headers: { 'Accept' => 'application/xml' }

    assert_illegal_or_missing_args_response
  end

  def test_unexpected_arg_xml_post
    post oaisys_path(verb: 'ListMetadataFormats', nastyParam: 'nasty'),
         headers: { 'Content-Type' => 'application/x-www-form-urlencoded', 'Content-Length' => 82 }
    assert_illegal_or_missing_args_response
  end

  def test_missing_required_arg_xml_post
    # Missing required metadataPrefix param
    get oaisys_path(verb: 'ListRecords'), headers: { 'Accept' => 'application/xml' }

    assert_illegal_or_missing_args_response
  end

  def test_missing_required_arg_xml
    # Missing required metadataPrefix param
    post oaisys_path(verb: 'ListRecords'), headers: { 'Content-Type' => 'application/x-www-form-urlencoded',
                                                      'Content-Length' => 82 }
    assert_illegal_or_missing_args_response
  end

  def assert_illegal_or_missing_args_response
    assert_response :success

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
