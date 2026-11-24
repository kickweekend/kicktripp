Sequel.seed(:development, :test) do
  def run
    trip = Kicktripp::Trip.first(title: "Япония 2027")
    place = Kicktripp::Place.first(name: "Tokyo National Museum")
    Kicktripp::Activity.create(trip_id: trip.id, place_id: place.id, title: "Посещение музея", starts_at: Time.iso8601("2027-04-02T10:00:00+09:00"), ends_at: Time.iso8601("2027-04-02T12:00:00+09:00"))
    Kicktripp::Activity.create(trip_id: trip.id, title: "Прогулка", starts_at: Time.iso8601("2027-04-03T10:00:00+09:00"), ends_at: Time.iso8601("2027-04-03T12:00:00+09:00"))
  end
end
