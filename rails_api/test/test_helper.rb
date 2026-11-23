ENV["RAILS_ENV"] ||= "test"
require_relative "../config/environment"
require "rails/test_help"
ActiveRecord::Migration.check_pending_migrations

class ActiveSupport::TestCase
  # Тестовая роль не имеет CREATEDB, поэтому без parallelize и клонирования БД.
  def create_plan
    @owner = User.create!(name: "Alex", email: "alex@example.test", interests: "museums")
    @guest = User.create!(name: "Maria", email: "maria@example.test", interests: "hiking")
    @trip = @owner.trips.create!(title: "Japan", starts_on: "2027-04-01", ends_on: "2027-04-10", budget_amount: 10000, currency: "JPY", time_zone: "Asia/Tokyo")
    @destination = @trip.destinations.create!(country: "Japan", city: "Tokyo", arrival_on: "2027-04-01", departure_on: "2027-04-10")
    @place = @destination.places.create!(name: "Museum", category: "museum")
    @activity = @trip.activities.create!(title: "Museum visit", place: @place, starts_at: "2027-04-02T10:00:00+09:00", ends_at: "2027-04-02T12:00:00+09:00")
    @participation = @activity.participations.create!(user: @guest)
  end
end
