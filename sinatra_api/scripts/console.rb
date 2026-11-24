require_relative "../config/database"
require_relative "../models/init"
require "irb"
DB = Kicktripp::DB
puts "kicktripp Sinatra console: DB, Kicktripp::Trip, Kicktripp::Activity"
IRB.start
