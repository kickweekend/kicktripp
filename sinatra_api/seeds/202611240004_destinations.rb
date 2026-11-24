Sequel.seed(:development, :test) do
  def run
    trip = Kicktripp::Trip.first(title: "Япония 2027")
    Kicktripp::Destination.create(trip_id: trip.id, country: "Japan", city: "Tokyo", arrival_on: trip.starts_on, departure_on: trip.ends_on)
    trip = Kicktripp::Trip.first(title: "Поездка в Казань")
    Kicktripp::Destination.create(trip_id: trip.id, country: "Russia", city: "Kazan", arrival_on: trip.starts_on, departure_on: trip.ends_on)
  end
end
