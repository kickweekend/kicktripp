require_relative "test_helper"
require_relative "../examples/classic_app"

class ClassicTest < ApiTest
  def app
    Sinatra::Application
  end

  def test_classic_application_and_named_route
    get "/"
    assert_json
    assert_equal "classic", body["style"]
    get "/hello/Alex"
    assert_equal "Hello, Alex!", body["message"]
  end

  def test_namespace_precedes_catch_all
    get "/api/v1/hello/Maria"
    assert_json
    assert_equal "API welcomes Maria", body["message"]
    get "/friends"
    assert_json 404
    assert_equal ["friends"], body["parts"]
  end
end
