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

get "/count" do
  User.count
end
