set :bind, "127.0.0.1"
set :port, Integer(ENV.fetch("PORT", "4567"))
set :server, :puma
set :show_exceptions, false
