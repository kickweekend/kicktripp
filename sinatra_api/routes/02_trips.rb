namespace "/api/v1" do
  get "/trips" do
    json_response(Kicktripp::DemoTrips.all)
  end

  get "/trips/:id" do
    trip = Kicktripp::DemoTrips.find(params[:id])
    unless trip
      @not_found_response = { error: "trip_not_found" }
      halt 404
    end
    json_response(trip)
  end

  # Маска в конце namespace не перехватывает определённые выше маршруты.
  get "/*" do
    @not_found_response = { error: "api_route_not_found", parts: params[:splat] }
    halt 404
  end
end
