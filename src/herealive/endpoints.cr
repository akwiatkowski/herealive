require "json"
require "./std/time"

get "/" do
  File.read("public/index.html")
end

post "/" do
  File.read("public/index.html")
end

post "/api/sign_up" do |env|
  env.response.content_type = "application/json"

  email = env.params.body["email"]
  password = env.params.body["password"]

  if User.validate(email: email, password: password)
    user = User.register(email, password)
    user.to_json
  else
    env.response.status_code = 422
    nil.to_json
  end
end

get "/api/profile" do |env|
  env.response.content_type = "application/json"
  env.current_user.to_json
end

post "/api/ping" do |env|
  env.response.content_type = "application/json"

  cu = env.current_user
  params = env.params.body

  # HTTP::Params(@raw_params={"accuracy" => ["41"], "altitude" => [""], "altitudeAccuracy" => [""], "heading" => [""], "lat" => ["52.4616711"], "lon" => ["16.9094083"], "place" => [""], "speed" => [""], "source" => ["js"]})


  if cu["id"]?
    h = {
      "user_id" => cu["id"].to_s.to_i,
      "lat" => params["lat"].to_s.to_f,
      "lon" => params["lon"].to_s.to_f,
      "manually" => true
    }
    ping = Ping.create(h)
    ping.to_json
  else
    nil.to_json
  end
end

get "/count" do
  User.count
end
