require 'test_helper'

class IdentifyTest < ActionDispatch::IntegrationTest

  include Oaisys::Engine.routes.url_helpers

  setup do
    @routes = Oaisys::Engine.routes
    # Set an action on unpermitted parameters to raise an exception, used to validate parameters.
    ActionController::Parameters.action_on_unpermitted_parameters = :raise
  end

  def test_identify_xml
    get oaisys_path(verb: 'Identify'), headers: { 'Accept' => 'application/xml' }
    assert_response :success

    schema = Nokogiri::XML::Schema(File.open(file_fixture('OAI-PMH.xsd')))
    document = Nokogiri::XML(@response.body)
    assert_empty schema.validate(document)

    assert_select 'OAI-PMH' do
      assert_select 'responseDate'
      assert_select 'request', 'https://era.library.ualberta.ca/oai'
      assert_select 'Identify' do
        assert_select 'repositoryName', 'ERA: Education and Research Archive'
        assert_select 'baseURL', 'https://era.library.ualberta.ca/oai'
        assert_select 'protocolVersion', '2.0'
        assert_select 'adminEmail', 'eraadmi@ualberta.ca'
        assert_select 'earliestDatestamp'
        assert_select 'deletedRecord', 'no'
        assert_select 'granularity', 'YYYY-MM-DDThh:mm:ssZ'
        assert_select 'description' do
          assert_select 'oai-id|oai-identifier' do
            assert_select 'oai-id|scheme', 'oai'
            assert_select 'oai-id|repositoryIdentifier', 'era.library.ualberta.ca'
            assert_select 'oai-id|delimiter', ':'
            assert_select 'oai-id|sampleIdentifier', 'oai:era.library.ualberta.ca:1d7047d8-f164-45bb-b62c-ae6045eb0c42'
          end
        end
      end
    end
  end

end
