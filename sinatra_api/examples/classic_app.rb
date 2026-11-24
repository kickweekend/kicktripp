require "bundler/setup"
require "sinatra"
require "sinatra/namespace"
require "json"

set :bind, "127.0.0.1"
set :port, Integer(ENV.fetch("PORT", "4567"))
set :server, :puma
before { content_type :json }

get "/" do
  JSON.generate(service: "kicktripp", style: "classic")
end

get "/hello/:name" do
  JSON.generate(message: "Hello, #{params[:name]}!")
end

namespace "/api/v1" do
  get "/hello/:name" do
    JSON.generate(message: "API welcomes #{params[:name]}")
  end
end

# Этот маршрут обязательно последний.
get "/*" do
  status 404
  JSON.generate(error: "not_found", parts: params[:splat])
end
