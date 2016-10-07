secret_file = File.join(["config", "secret.txt"])
if File.exists?(secret_file)
  secret_key = File.read(secret_file).strip
else
  secret_key = SecureRandom.hex
  File.open(secret_file, "w") do |f|
    f.puts(secret_key)
  end
end

auth_token_mw = Kemal::AuthToken.new(
  secret_key: secret_key
)
auth_token_mw.path = "/api/sign_in"

auth_token_mw.sign_in do |email, password|
  User.sign_in(email, password)
end
auth_token_mw.load_user do |user|
  User.load_user(user)
end

Kemal.config.add_handler(auth_token_mw)
