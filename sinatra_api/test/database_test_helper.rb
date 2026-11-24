require_relative "test_helper"
require_relative "../app"
raise "Tests require a distinct test database" unless Kicktripp::ENVIRONMENT == "test" && Kicktripp::DB.database_type == :postgres
%w[User Trip Destination Place Activity Expense Participation].each do |name|
  Object.const_set(name, Kicktripp.const_get(name)) unless Object.const_defined?(name)
end

class DatabaseTest < ApiTest
  def app = Sinatra::Application

  def run
    Kicktripp::DB.transaction(rollback: :always, auto_savepoint: true) { super }
  end

  def create_plan
    @owner = User.create(name: "Alex", email: "alex@example.test", interests: "museums")
    @guest = User.create(name: "Maria", email: "maria@example.test", interests: "hiking")
    @trip = Trip.create(user_id: @owner.id, title: "Japan", starts_on: Date.new(2027,4,1), ends_on: Date.new(2027,4,10), budget_amount: 10000, currency: "JPY", time_zone: "Asia/Tokyo")
    @destination = Destination.create(trip_id: @trip.id, country: "Japan", city: "Tokyo", arrival_on: @trip.starts_on, departure_on: @trip.ends_on)
    @place = Place.create(destination_id: @destination.id, name: "Museum", category: "museum")
    @activity = Activity.create(trip_id: @trip.id, title: "Museum visit", place_id: @place.id, starts_at: Time.iso8601("2027-04-02T10:00:00+09:00"), ends_at: Time.iso8601("2027-04-02T12:00:00+09:00"))
    @participation = Participation.create(activity_id: @activity.id, user_id: @guest.id)
  end

  STATUS = { ok: 200, created: 201, no_content: 204, not_found: 404, bad_request: 400, unprocessable_entity: 422 }.freeze
  def assert_response(code)
    assert_equal STATUS.fetch(code, code), last_response.status, last_response.body
  end
  def assert_not(value, message = nil) = refute(value, message)

  # Совместимый интерфейс отправки запросов для сравнения с Rails request tests.
  def post(path, data = nil, params: nil, as: nil, headers: {})
    send_request(:post, path, params || data, as, headers)
  end
  def put(path, data = nil, params: nil, as: nil, headers: {})
    send_request(:put, path, params || data, as, headers)
  end
  def patch(path, data = nil, params: nil, as: nil, headers: {})
    send_request(:patch, path, params || data, as, headers)
  end
  def delete(path) = super(path)
  def get(path, data = nil, params: nil) = super(path, params || data || {})

  def send_request(method, path, data, encoding, headers)
    env = headers.dup
    env["CONTENT_TYPE"] = "application/json" if encoding == :json
    payload = encoding == :json ? JSON.generate(data) : data
    rack_test_session.custom_request(method.to_s.upcase, path, payload, env)
  end
end
