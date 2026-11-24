Sequel.seed(:development, :test) do
  def run
    destination = Kicktripp::Destination.first(city: "Tokyo")
    Kicktripp::Place.create(destination_id: destination.id, name: "Tokyo National Museum", category: "museum", address: "Ueno Park")
  end
end
