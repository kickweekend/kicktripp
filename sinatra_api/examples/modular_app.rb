require "bundler/setup"
require "sinatra/base"
require "sinatra/namespace"
require "json"

module Kicktripp
  class ModularApp < Sinatra::Base
    register Sinatra::Namespace
    set :bind, "127.0.0.1"
    set :port, Integer(ENV.fetch("PORT", "4567"))
    set :server, :puma
    before { content_type :json }

    get "/" do
      JSON.generate(service: "kicktripp", style: "modular")
    end

    get "/hello/:name" do |name|
      JSON.generate(message: "Hello, #{name}!")
    end

    namespace "/api/v1" do
      get "/hello/:name" do
        JSON.generate(message: "API welcomes #{params[:name]}")
      end
    end

    not_found do
      JSON.generate(error: "not_found")
    end

    run! if app_file == $PROGRAM_NAME
  end
end
