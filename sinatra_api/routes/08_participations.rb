namespace "/api/v1" do
  get "/participations" do
    collection_json(boolean_filter(boolean_filter(participations_scope, :read), :invited))
  end

  get "/participations/:id" do
    json_response(record!(participations_scope, params[:id]).to_api)
  end

  post "/participations" do
    participation = Kicktripp::Participation.new(input(:user_id, :activity_id, :read, :invited))
    participation.save
    respond(participation.refresh.to_api, 201)
  end

  ["PUT", "PATCH"].each do |method|
    public_send(method.downcase, "/participations/:id") do
      participation = record!(participations_scope, params[:id])
      participation.set(input(:read, :invited))
      participation.save
      json_response(participation.refresh.to_api)
    end
  end

  delete "/participations/:id" do
    participation = record!(participations_scope, params[:id])
    participation.destroy
    status 204
    body ""
  end
end
