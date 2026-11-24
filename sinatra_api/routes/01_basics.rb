get("/up") { json_response(status: "ok") }

get "/" do
  json_response(service: "kicktripp", framework: "Sinatra", storage: "postgresql", trips_url: "/api/v1/trips")
end

get "/hello/:name" do
  json_response(message: "Sinatra приветствует тебя, #{params[:name]}!")
end

get "/hello-block/:name" do |name|
  json_response(message: "Hello, #{name}!")
end

get "/redirect" do
  redirect to("/hello/World"), 302
end

get %r{/meta/hello/(\w+)(?:/.*)?} do |name|
  json_response(message: "Hello, #{name}!")
end

get "/say/*/to/*" do
  json_response(parts: params[:splat])
end

get "/download/*.*" do |path, extension|
  # Демонстрация параметров маршрута; файл с диска не читается.
  json_response(path: path, extension: extension)
end

get "/demo/trips.?:format?" do
  json_response(message: "Маршрут с необязательным форматом", requested_format: params[:format] || "none")
end

# Sinatra выбирает первый совпавший маршрут: специальный вариант идёт раньше общего.
get "/order/special" do
  json_response(matched: "specific")
end

get "/order/:name" do
  json_response(matched: "parameter", name: params[:name])
end
