require_relative "database_test_helper"

class BasicsTest < DatabaseTest
  def setup
    super
    create_plan
  end

  def app
    Sinatra::Application
  end

  def test_root_identifies_service_and_demo_storage
    get "/"
    assert_json
    assert_equal "kicktripp", body["service"]
    assert_equal "postgresql", body["storage"]
  end

  def test_named_parameter_from_hash_and_block
    get "/hello/Alex"
    assert_json
    assert_includes body["message"], "Alex"
    get "/hello-block/Maria"
    assert_json
    assert_equal "Hello, Maria!", body["message"]
  end

  def test_redirect_can_be_followed
    get "/redirect"
    assert_equal 302, last_response.status
    assert_equal "http://localhost/hello/World", last_response.headers["location"]
    follow_redirect!
    assert_json
    assert_includes body["message"], "World"
  end

  def test_regex_capture_with_and_without_trailing_path
    ["/meta/hello/world", "/meta/hello/world/123"].each do |url|
      get url
      assert_json
      assert_equal "Hello, world!", body["message"]
    end
  end

  def test_splat_captures_two_separate_parts
    get "/say/hello/to/world"
    assert_json
    assert_equal ["hello", "world"], body["parts"]
  end

  def test_download_splat_only_parses_path_and_extension
    get "/download/path/to/file.xml"
    assert_json
    assert_equal({ "path" => "path/to/file", "extension" => "xml" }, body)
  end

  def test_optional_parameter_does_not_change_json_response_type
    { "/demo/trips" => "none", "/demo/trips.json" => "json", "/demo/trips.xml" => "xml" }.each do |url, format|
      get url
      assert_json
      assert_equal format, body["requested_format"]
    end
  end

  def test_first_matching_route_wins
    get "/order/special"
    assert_json
    assert_equal "specific", body["matched"]
    get "/order/ordinary"
    assert_equal "parameter", body["matched"]
    assert_equal "ordinary", body["name"]
  end

  def test_namespaced_list_and_single_trip
    get "/api/v1/trips"
    assert_json
    assert_equal 1, body.length
    assert_equal "Japan", body.first["title"]
    get "/api/v1/trips/#{@trip.id}"
    assert_json
    assert_equal @trip.id, body["id"]
  end

  def test_missing_record_returns_json_404
    ["/api/v1/trips/999", "/api/v1/trips/not-an-id"].each do |url|
      get url
      assert_json 404
      assert_equal "not_found", body["error"]
    end
  end

  def test_namespaced_wildcard_does_not_hide_existing_routes
    get "/api/v1/friends"
    assert_json 404
    assert_equal "route_not_found", body["error"]
    assert_equal ["friends"], body["parts"]
    get "/trips"
    assert_json 404
    assert_equal "route_not_found", body["error"]
  end

  def test_unknown_route_and_invalid_creation
    get "/missing"
    assert_json 404
    assert_equal "route_not_found", body["error"]
    post "/api/v1/trips", params: { title: "Invalid trip" }, as: :json
    assert_json 422
    get "/api/v1/trips"
    assert_equal 1, body.length
  end
end
