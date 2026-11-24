namespace "/api/v1" do
  get "/trips/:trip_id/activities" do
    scope = activities_scope
    scope = scope.by_title(params[:title]) if params[:title]
    scope = scope.by_place(params[:place]) if params[:place]
    scope = scope.where(status: params[:status]) if params[:status]
    if params[:on]
      date = date_filter
      records = scope.eager(:trip).order(:id).all.select { |activity| activity.trip.zone.utc_to_local(activity.starts_at.to_time.utc).to_date == date }
      json_response(records.map(&:to_api))
    else
      collection_json(scope)
    end
  end

  get "/trips/:trip_id/activities/:id" do
    json_response(record!(activities_scope, params[:id]).to_api)
  end

  post "/trips/:trip_id/activities" do
    activities_scope
    activity = Kicktripp::Activity.new(input(:place_id, :title, :starts_at, :ends_at, :notes, :status).merge(trip_id: current_trip.id))
    activity.save
    respond(activity.refresh.to_api, 201)
  end

  ["PUT", "PATCH"].each do |method|
    public_send(method.downcase, "/trips/:trip_id/activities/:id") do
      activity = record!(activities_scope, params[:id])
      activity.set(input(:place_id, :title, :starts_at, :ends_at, :notes, :status))
      activity.save
      json_response(activity.refresh.to_api)
    end
  end

  delete "/trips/:trip_id/activities/:id" do
    activity = record!(activities_scope, params[:id])
    activity.mark_deleted
    status 204
    body ""
  end

  put "/trips/:trip_id/activities/:id/mark_deleted" do
    record!(activities_scope, params[:id]).mark_deleted
    status 204
    body ""
  end
end
