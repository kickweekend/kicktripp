require "bundler/setup"
require "sinatra"
require "sinatra/namespace"
require "json"
require "multi_json"
require_relative "config/database"
require_relative "config/settings"
require_relative "helpers/json_helpers"
require_relative "helpers/api_helpers"
require_relative "models/init"
Dir[File.join(__dir__, "controllers", "*.rb")].sort.each { |file| require file }
Dir[File.join(__dir__, "routes", "*.rb")].sort.each { |file| require file }
