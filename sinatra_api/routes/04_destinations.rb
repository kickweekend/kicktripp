namespace "/api/v1" do
  get "/trips/:trip_id/destinations" do
    collection_json(destinations_scope)
  end

  get "/trips/:trip_id/destinations/:id" do
    json_response(record!(destinations_scope, params[:id]).to_api)
  end

  post "/trips/:trip_id/destinations" do
    destinations_scope
    destination = Kicktripp::Destination.new(input(:country, :city, :arrival_on, :departure_on, :position).merge(trip_id: current_trip.id))
    destination.save
    respond(destination.refresh.to_api, 201)
  end

  ["PUT", "PATCH"].each do |method|
    public_send(method.downcase, "/trips/:trip_id/destinations/:id") do
      destination = record!(destinations_scope, params[:id])
      destination.set(input(:country, :city, :arrival_on, :departure_on, :position))
      destination.save
      json_response(destination.refresh.to_api)
    end
  end

  delete "/trips/:trip_id/destinations/:id" do
    destination = record!(destinations_scope, params[:id])
    destination.destroy
    status 204
    body ""
  end
end
