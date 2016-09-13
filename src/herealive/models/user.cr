crystal_model(
  User,
  id : (Int32 | Nil) = nil,
  email : (String | Nil) = nil,
  hashed_password : (String | Nil) = nil
)
crystal_resource(user, users, User)


struct User
  # Return id in UserHash if user is signed ok
  def self.sign_in(email : String, password : String) : UserHash
    h = {
      "email"           => email,
      "hashed_password" => Crypto::MD5.hex_digest(password),
    }

    # try sign in using handle
    user = User.fetch_one(where: h)

    uh = UserHash.new
    if user
      uh["id"] = user.id
    end
    return uh
  end

  # Return email and handle if user can be loaded
  def self.load_user(user : Hash) : UserHash
    uh = UserHash.new
    return uh if user["id"].to_s == ""

    h = {
      "id" => user["id"].to_s.to_i.as(Int32),
    }
    user = User.fetch_one(h)

    if user
      uh["id"] = user.id
      uh["email"] = user.email
    end
    return uh
  end
end
