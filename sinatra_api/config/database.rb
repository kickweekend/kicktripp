require "bundler/setup"
require "dotenv"
require "sequel"
require "pg"
require "date"
require "time"
require "bigdecimal"
require "tzinfo"
Dotenv.load(File.expand_path("../.env", __dir__))

module Kicktripp
  ENVIRONMENT = ENV.fetch("APP_ENV", ENV.fetch("RACK_ENV", "development"))
  raise "APP_ENV must be development, test or production" unless %w[development test production].include?(ENVIRONMENT)
  if ENV.fetch("SINATRA_TEST_DATABASE", "kicktripp_sinatra_test") == ENV.fetch("SINATRA_DEVELOPMENT_DATABASE", "kicktripp_sinatra_development")
    raise "Development and test databases must be different"
  end
  Sequel.default_timezone = :utc
  database = ENVIRONMENT == "production" ? ENV.fetch("SINATRA_PRODUCTION_DATABASE") : ENV.fetch("SINATRA_#{ENVIRONMENT.upcase}_DATABASE", "kicktripp_sinatra_#{ENVIRONMENT}")
  unless database.start_with?("kicktripp_sinatra_")
    raise "Use separate kicktripp_sinatra_* databases, never a Rails database"
  end
  DB = Sequel.connect(adapter: "postgres", host: ENV.fetch("PGHOST", "127.0.0.1"),
    port: ENV.fetch("PGPORT", "5432").to_i, database: database,
    user: ENV.fetch("PGUSER", "kicktripp_sinatra"), password: ENV["PGPASSWORD"], max_connections: 5, driver_options: { application_name: "kicktripp_sinatra" })
end
