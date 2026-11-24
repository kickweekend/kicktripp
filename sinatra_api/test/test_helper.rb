ENV["APP_ENV"] = "test"
ENV["RACK_ENV"] = "test"
require "minitest/autorun"
require "rack/test"
require "json"

class ApiTest < Minitest::Test
  include Rack::Test::Methods

  def setup
    header "Host", "localhost"
  end

  def body
    JSON.parse(last_response.body)
  end

  def assert_json(status = 200)
    assert_equal status, last_response.status
    assert_includes last_response.content_type, "application/json"
  end
end
