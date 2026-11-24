require "bundler/setup"
require "dotenv/load"
require "sinatra"
require "sinatra/namespace"
require "json"
require "multi_json"
require "pg"
require "sequel"
require "sequel/extensions/seed"

require_relative "config/settings"
require_relative "helpers/json_helpers"

# Порядок загрузки задан явно; пути не зависят от текущего каталога терминала.
%w[models controllers routes].each do |directory|
  Dir[File.join(__dir__, directory, "*.rb")].sort.each { |file| require file }
end
