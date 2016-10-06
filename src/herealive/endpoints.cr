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
    manually = true
    manually = false if params["lat"].to_s == "app_auto"

    h = Hash(String, (Int32 | Float64 | String | Bool)).new

    h["user_id"] = cu["id"].to_s.to_i
    h["lat"] = params["lat"].to_s.to_f if params["lat"].to_s != ""
    h["lon"] = params["lon"].to_s.to_f if params["lon"].to_s != ""
    h["accuracy"] = params["accuracy"].to_s.to_i if params["accuracy"].to_s != ""
    h["altitude"] = params["altitude"].to_s.to_i if params["altitude"].to_s != ""
    h["altitudeAccuracy"] = params["altitudeAccuracy"].to_s.to_i if params["altitudeAccuracy"].to_s != ""
    h["heading"] = params["heading"].to_s.to_i if params["heading"].to_s != ""
    h["speed"] = params["speed"].to_s.to_i if params["speed"].to_s != ""
    h["manually"] = manually

    h["source"] = params["source"].to_s
    h["location"] = params["location"].to_s

    ping = Ping.create(h)
    ping.to_json
  else
    nil.to_json
  end
end

get "/api/ping/last" do |env|
  env.response.content_type = "application/json"
  cu = env.current_user

  ping = Ping.fetch_one(
    where: {"user_id" => cu["id"].to_s.to_i},
    order: "pings.id DESC"
  )
  ping.to_json
end

get "/api/ping" do |env|
  env.response.content_type = "application/json"
  cu = env.current_user

  ping = Ping.fetch_all(
    where: {"user_id" => cu["id"].to_s.to_i},
    order: "pings.id DESC",
    limit: 5
  )
  ping.to_json
end

get "/api/u/:public_handle" do |env|
  # CrystalService.logging = true

  env.response.content_type = "application/json"

  if env.params.url["public_handle"]?
    user = User.fetch_one(
      where: {"public_handle" => env.params.url["public_handle"]}
    )

    if user
      user.public.to_json
    else
      nil.to_json
    end
  else
    nil.to_json
  end
end

get "/count" do
  User.count
end
