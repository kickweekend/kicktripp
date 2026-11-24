namespace "/api/v1" do
  get "/trips" do
    scope = Kicktripp::Trip.visible
    scope = scope.by_title(params[:title]) if params[:title]
    scope = scope.by_city(params[:city]) if params[:city]
    if params[:user_id]
      halt 400, json_response(error: "bad_request") unless params[:user_id].match?(/\A[0-9]+\z/)
      scope = scope.where(user_id: params[:user_id].to_i)
    end
    if params[:on]
      date = date_filter
      scope = scope.where(Sequel[:starts_on] <= date).where(Sequel[:ends_on] >= date)
    end
    collection_json(scope)
  end

  get "/trips/:id" do
    json_response(record!(Kicktripp::Trip.visible, params[:id]).to_api)
  end

  post "/trips" do
    trip = Kicktripp::Trip.new(input(:user_id, :title, :description, :starts_on, :ends_on, :budget_amount, :currency, :time_zone))
    trip.save
    respond(trip.refresh.to_api, 201)
  end

  ["PUT", "PATCH"].each do |method|
    public_send(method.downcase, "/trips/:id") do
      trip = record!(Kicktripp::Trip.visible, params[:id])
      trip.set(input(:user_id, :title, :description, :starts_on, :ends_on, :budget_amount, :currency, :time_zone))
      trip.save
      json_response(trip.refresh.to_api)
    end
  end

  delete "/trips/:id" do
    trip = record!(Kicktripp::Trip.visible, params[:id])
    trip.mark_deleted
    status 204
    body ""
  end

  put "/trips/:id/mark_deleted" do
    record!(Kicktripp::Trip.visible, params[:id]).mark_deleted
    status 204
    body ""
  end
end
