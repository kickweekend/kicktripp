require_relative "test_helper"
require_relative "../examples/modular_app"

class ModularTest < ApiTest
  def app
    Kicktripp::ModularApp
  end

  def test_modular_application_and_named_route
    get "/"
    assert_json
    assert_equal "modular", body["style"]
    get "/hello/Alex"
    assert_equal "Hello, Alex!", body["message"]
  end

  def test_namespace_and_missing_route
    get "/api/v1/hello/Maria"
    assert_json
    assert_equal "API welcomes Maria", body["message"]
    get "/friends"
    assert_json 404
    assert_equal "not_found", body["error"]
  end
end
