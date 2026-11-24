namespace "/api/v1" do
  get "/trips/:trip_id/destinations/:destination_id/places" do
    collection_json(places_scope)
  end

  get "/trips/:trip_id/destinations/:destination_id/places/:id" do
    json_response(record!(places_scope, params[:id]).to_api)
  end

  post "/trips/:trip_id/destinations/:destination_id/places" do
    places_scope
    place = Kicktripp::Place.new(input(:name, :category, :address, :description).merge(destination_id: record!(destinations_scope, params[:destination_id]).id))
    place.save
    respond(place.refresh.to_api, 201)
  end

  ["PUT", "PATCH"].each do |method|
    public_send(method.downcase, "/trips/:trip_id/destinations/:destination_id/places/:id") do
      place = record!(places_scope, params[:id])
      place.set(input(:name, :category, :address, :description))
      place.save
      json_response(place.refresh.to_api)
    end
  end

  delete "/trips/:trip_id/destinations/:destination_id/places/:id" do
    place = record!(places_scope, params[:id])
    place.destroy
    status 204
    body ""
  end
end
