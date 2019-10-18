require 'test_helper'

module Oaisys
  class PMHControllerTest < ActionDispatch::IntegrationTest
    include Engine.routes.url_helpers

    setup do
      @routes = Engine.routes
    end

    def test_bad_verb_route
      assert_recognizes({ controller: 'oaisys/pmh', action: 'bad_verb' }, { path: '?verb=NastyVerb', method: :post })
      assert_recognizes({ controller: 'oaisys/pmh', action: 'bad_verb' }, { path: '?verb=NastyVerb', method: :get })
      assert_recognizes({ controller: 'oaisys/pmh', action: 'bad_verb' }, { path: '', method: :post })
      assert_recognizes({ controller: 'oaisys/pmh', action: 'bad_verb' }, { path: '', method: :get })
    end

    def test_identify_route
      assert_recognizes({ controller: 'oaisys/pmh', action: 'identify' }, { path: '?verb=Identify', method: :post })
      assert_recognizes({ controller: 'oaisys/pmh', action: 'identify' }, { path: '?verb=Identify', method: :get })
    end

    def test_list_sets_route
      assert_recognizes({ controller: 'oaisys/pmh', action: 'list_sets' }, { path: '?verb=ListSets', method: :post })
      assert_recognizes({ controller: 'oaisys/pmh', action: 'list_sets' }, { path: '?verb=ListSets', method: :get })
    end

    def test_list_metadata_formats_route
      assert_recognizes({ controller: 'oaisys/pmh', action: 'list_metadata_formats' }, { path: '?verb=ListMetadataFormats', method: :post })
      assert_recognizes({ controller: 'oaisys/pmh', action: 'list_metadata_formats' }, { path: '?verb=ListMetadataFormats', method: :get })
    end

    def test_list_records_route
      assert_recognizes({ controller: 'oaisys/pmh', action: 'list_records' }, { path: '?verb=ListRecords', method: :post })
      assert_recognizes({ controller: 'oaisys/pmh', action: 'list_records' }, { path: '?verb=ListRecords', method: :get })
    end

    def test_get_record_route
      assert_recognizes({ controller: 'oaisys/pmh', action: 'get_record' }, { path: '?verb=GetRecord', method: :post })
      assert_recognizes({ controller: 'oaisys/pmh', action: 'get_record' }, { path: '?verb=GetRecord', method: :get })
    end

    def test_list_identifiers_route
      assert_recognizes({ controller: 'oaisys/pmh', action: 'list_identifiers' }, { path: '?verb=ListIdentifiers', method: :post })
      assert_recognizes({ controller: 'oaisys/pmh', action: 'list_identifiers' }, { path: '?verb=ListIdentifiers', method: :get })
    end

    def test_no_route_matches_unsupported_http_verbs
      assert_raises(ActionController::RoutingError) do
        patch oaisys_path
      end

      assert_raises(ActionController::RoutingError) do
        put oaisys_path
      end

      assert_raises(ActionController::RoutingError) do
        delete oaisys_path
      end
    end
  end
end
