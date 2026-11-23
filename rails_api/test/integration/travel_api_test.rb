require "test_helper"

class TravelApiTest < ActionDispatch::IntegrationTest
  setup { create_plan }

  def base
    "/api/v1/trips/#{@trip.id}"
  end

  def body
    response.parsed_body
  end

  def assert_json_error(code)
    assert_response code
    assert_equal "application/json", response.media_type
    assert body.key?("error") || body.key?("errors")
  end

  test "CRUD users with profile and validation" do
    post "/api/v1/users", params: { name: "New", email: "NEW@example.test", interests: "art" }, as: :json
    assert_response :created
    id = body.fetch("id")
    assert_equal "new@example.test", body["email"]
    put "/api/v1/users/#{id}", params: { bio: "Люблю путешествовать" }, as: :json
    assert_response :ok
    assert_equal "Люблю путешествовать", body["bio"]
    get "/api/v1/users/#{id}"
    assert_response :ok
    delete "/api/v1/users/#{id}"
    assert_response :no_content
    assert_not User.exists?(id)
    post "/api/v1/users", params: { name: "Duplicate", email: @owner.email.upcase }, as: :json
    assert_json_error :unprocessable_entity
    post "/api/v1/users", params: { name: "Invalid", email: "invalid" }, as: :json
    assert_json_error :unprocessable_entity
    delete "/api/v1/users/#{@owner.id}"
    assert_json_error :unprocessable_entity
  end

  test "trip CRUD and soft deletion" do
    post "/api/v1/trips", params: { user_id: @owner.id, title: "New", starts_on: "2027-05-01", ends_on: "2027-05-03", currency: "RUB" }, as: :json
    assert_response :created
    id = body["id"]
    patch "/api/v1/trips/#{id}", params: { title: "Updated" }, as: :json
    assert_response :ok
    assert_equal "Updated", body["title"]
    delete "/api/v1/trips/#{id}"
    assert_response :no_content
    assert Trip.find(id).deleted?
    get "/api/v1/trips/#{id}"
    assert_json_error :not_found
    delete "/api/v1/trips/#{id}"
    assert_json_error :not_found
  end

  test "partial filters independently and together including escaped SQL wildcards" do
    get "/api/v1/trips", params: { title: "jAP", city: "tok" }
    assert_response :ok
    assert_equal [@trip.id], body.map { |r| r["id"] }
    get "/api/v1/trips", params: { city: "tok" }
    assert_equal 1, body.size
    get "/api/v1/trips", params: { title: "%" }
    assert_equal [], body
    get "/api/v1/users", params: { interests: "hik", name: "MAR" }
    assert_equal [@guest.id], body.map { |r| r["id"] }
    get "/api/v1/activities", params: { title: "visit", place: "mus", status: "planned", on: "2027-04-02" }
    assert_response :ok
    assert_equal [@activity.id], body.map { |r| r["id"] }
    get "/api/v1/trips", params: { on: "2027-04-03" }
    assert_equal 1, body.size
    get "/api/v1/trips", params: { on: "bad" }
    assert_json_error :bad_request
    get "/api/v1/trips", params: { title: "missing" }
    assert_response :ok
    assert_equal [], body
  end

  test "destination and place CRUD with restricted parent removal" do
    post "#{base}/destinations", params: { country: "Japan", city: "Kyoto", arrival_on: "2027-04-04", departure_on: "2027-04-05" }, as: :json
    assert_response :created
    destination_id = body["id"]
    path = "#{base}/destinations/#{destination_id}"
    put path, params: { city: "Osaka" }, as: :json
    assert_response :ok
    get path
    assert_equal "Osaka", body["city"]
    post "#{path}/places", params: { name: "Park", category: "nature" }, as: :json
    assert_response :created
    place_id = body["id"]
    patch "#{path}/places/#{place_id}", params: { address: "Center" }, as: :json
    assert_response :ok
    get "#{path}/places"
    assert_equal 1, body.size
    get "#{path}/places/#{place_id}"
    assert_equal "Center", body["address"]
    delete path
    assert_json_error :unprocessable_entity
    delete "#{path}/places/#{place_id}"
    assert_response :no_content
    delete path
    assert_response :no_content
    assert_not Destination.exists?(destination_id)
  end

  test "activity CRUD timezone filter and preserved deletion" do
    post "#{base}/activities", params: { title: "Walk", starts_at: "2027-04-03T00:30:00+09:00", ends_at: "2027-04-03T01:00:00+09:00" }, as: :json
    assert_response :created
    id = body["id"]
    get "#{base}/activities", params: { on: "2027-04-03" }
    assert_equal [id], body.map { |r| r["id"] }
    put "#{base}/activities/#{id}", params: { status: "completed" }, as: :json
    assert_response :ok
    get "#{base}/activities/#{id}"
    assert_equal "completed", body["status"]
    delete "#{base}/activities/#{id}"
    assert_response :no_content
    assert Activity.find(id).deleted?
    get "/api/v1/activities/#{id}"
    assert_json_error :not_found
  end

  test "invalid data and inconsistent changes are rejected" do
    post "/api/v1/trips", params: { user_id: @owner.id, title: "Invalid", starts_on: "2027-04-10", ends_on: "2027-04-01", budget_amount: -1, time_zone: "unknown" }, as: :json
    assert_json_error :unprocessable_entity
    post "#{base}/destinations", params: { city: "X", country: "X", arrival_on: "2027-04-09", departure_on: "2027-04-08" }, as: :json
    assert_json_error :unprocessable_entity
    patch base, params: { ends_on: "2027-04-01" }, as: :json
    assert_json_error :unprocessable_entity
    assert_equal Date.new(2027, 4, 10), @trip.reload.ends_on
    post "#{base}/activities", params: { title: "Bad", starts_at: "2027-04-02T12:00:00", ends_at: "2027-04-02T13:00:00" }, as: :json
    assert_json_error :bad_request
    patch "#{base}/activities/#{@activity.id}", params: { ends_at: "2027-04-01T10:00:00+09:00" }, as: :json
    assert_json_error :unprocessable_entity
    post "#{base}/expenses", params: { title: "Bad", category: "tickets", amount: -1, currency: "RUB", spent_on: "2027-04-02" }, as: :json
    assert_json_error :unprocessable_entity
  end

  test "expenses CRUD summary and currency invariant" do
    post "#{base}/expenses", params: { title: "Ticket", category: "tickets", amount: "100.25", currency: "JPY", spent_on: "2027-04-02", activity_id: @activity.id }, as: :json
    assert_response :created
    id = body["id"]
    assert_equal "100.25", body["amount"]
    patch "#{base}/expenses/#{id}", params: { amount: "200.50" }, as: :json
    assert_response :ok
    get "#{base}/expenses/#{id}"
    assert_response :ok
    get "#{base}/expenses"
    assert_equal 1, body.size
    get "#{base}/summary"
    assert_response :ok
    assert_equal "200.5", body["spent_amount"]
    assert_equal "9799.5", body["remaining_amount"]
    patch base, params: { currency: "RUB" }, as: :json
    assert_json_error :unprocessable_entity
    assert_equal "JPY", @trip.reload.currency
    delete "#{base}/expenses/#{id}"
    assert_response :no_content
  end

  test "foreign trip resources cannot be reached or linked" do
    other = @owner.trips.create!(title: "Other", starts_on: @trip.starts_on, ends_on: @trip.ends_on, currency: "JPY")
    get "/api/v1/trips/#{other.id}/activities/#{@activity.id}"
    assert_json_error :not_found
    get "/api/v1/trips/#{other.id}/activities/#{@activity.id}/participations"
    assert_json_error :not_found
    get "/api/v1/trips/#{other.id}/destinations/#{@destination.id}/places"
    assert_json_error :not_found
    post "/api/v1/trips/#{other.id}/activities", params: { title: "Bad link", place_id: @place.id, starts_at: @activity.starts_at.iso8601, ends_at: @activity.ends_at.iso8601 }, as: :json
    assert_json_error :unprocessable_entity
    post "/api/v1/trips/#{other.id}/expenses", params: { title: "Bad link", category: "tickets", activity_id: @activity.id, amount: 1, currency: "JPY", spent_on: "2027-04-02" }, as: :json
    assert_json_error :unprocessable_entity
  end

  test "participation lifecycle read invited and associated users" do
    get "/api/v1/participations", params: { read: false, invited: false }
    assert_response :ok
    assert_equal [@participation.id], body.map { |r| r["id"] }
    put "/api/v1/participations/#{@participation.id}", params: { read: true, invited: true }, as: :json
    assert_response :ok
    get "/api/v1/users/#{@guest.id}/participations", params: { read: true, invited: true }
    assert_equal 1, body.size
    get "/api/v1/activities/#{@activity.id}/participations"
    assert_equal 1, body.size
    get "/api/v1/activities/#{@activity.id}/users"
    assert_equal [@guest.id], body.map { |r| r["id"] }
    get "#{base}/users"
    assert_equal [@guest.id], body.map { |r| r["id"] }
    get "/api/v1/participations", params: { read: "bad" }
    assert_json_error :bad_request
    post "/api/v1/participations", params: { user_id: @guest.id, activity_id: @activity.id }, as: :json
    assert_json_error :unprocessable_entity
    delete "/api/v1/participations/#{@participation.id}"
    assert_response :no_content
    post "/api/v1/participations", params: { user_id: @guest.id, activity_id: @activity.id }, as: :json
    assert_response :created
    get "/api/v1/participations/#{body['id']}"
    assert_response :ok
  end

  test "deleted parent hides descendants and participation" do
    put "#{base}/mark_deleted"
    assert_response :no_content
    assert @trip.reload.deleted?
    assert Activity.exists?(@activity.id)
    get "#{base}/activities"
    assert_json_error :not_found
    get "/api/v1/activities/#{@activity.id}"
    assert_json_error :not_found
    get "/api/v1/participations/#{@participation.id}"
    assert_json_error :not_found
    get "/api/v1/trips"
    assert_equal [], body
  end

  test "unknown routes records malformed JSON and forbidden assignment" do
    get "/no-such-route"
    assert_json_error :not_found
    get "/api/v1/trips/99999999"
    assert_json_error :not_found
    post "/api/v1/users", params: "{broken", headers: { "CONTENT_TYPE" => "application/json" }
    assert_json_error :bad_request
    patch base, params: { deleted: true }, as: :json
    assert_response :ok
    assert_not @trip.reload.deleted?
    assert_equal %w[budget_amount created_at currency deleted description ends_on id starts_on time_zone title updated_at user_id], body.keys.sort
  end
end
