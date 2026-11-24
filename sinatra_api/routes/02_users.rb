namespace "/api/v1" do
  get "/users" do
    collection_json(filtered_users(Kicktripp::User.dataset))
  end

  get "/users/:id" do
    json_response(record!(Kicktripp::User.dataset, params[:id]).to_api)
  end

  post "/users" do
    user = Kicktripp::User.new(input(:name, :email, :interests, :bio))
    user.save
    respond(user.refresh.to_api, 201)
  end

  ["PUT", "PATCH"].each do |method|
    public_send(method.downcase, "/users/:id") do
      user = record!(Kicktripp::User.dataset, params[:id])
      user.set(input(:name, :email, :interests, :bio))
      user.save
      json_response(user.refresh.to_api)
    end
  end

  delete "/users/:id" do
    user = record!(Kicktripp::User.dataset, params[:id])
    user.destroy
    status 204
    body ""
  end
end
