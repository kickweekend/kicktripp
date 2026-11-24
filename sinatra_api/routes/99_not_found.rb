namespace "/api/v1" do
  get "/*" do
    @not_found_response = { error: "route_not_found", parts: params[:splat] }
    halt 404
  end
end
