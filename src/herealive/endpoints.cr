get "/" do
  File.read("public/index.html")
end

post "/" do
  File.read("public/index.html")
end

post "/api/sign_up" do |env|
  email = env.params.body["email"]
  password = env.params.body["password"]

  User.register(email, password)
end

get "/count" do
  User.count
end
