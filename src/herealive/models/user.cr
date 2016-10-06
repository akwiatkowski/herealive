crystal_model(
  User,
  id : (Int32 | Nil) = nil,
  email : (String | Nil) = nil,
  hashed_password : (String | Nil) = nil,
  created_at : (Time | Nil) = nil,
  updated_at : (Time | Nil) = nil
)
crystal_resource(user, users, User)


struct User

  def self.hash_password(p : String) : String
    return Crypto::MD5.hex_digest(p)
  end

  # Return id in UserHash if user is signed ok
  def self.sign_in(email : String, password : String) : UserHash
    h = {
      "email"           => email,
      "hashed_password" => hash_password(password),
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

  def self.register(email : String, password : String)
    User.create({
      "email" => email,
      "hashed_password" => hash_password(password),
      "created_at" => Time.now,
      "updated_at" => Time.now
    })
  end

  def self.validate(email : String, password : String)
    # check email uniq
    return false if User.count(where: {"email" => email}).to_s.to_i > 0
    # TODO email regexp
    return true if email.size > 3 && password.size > 3
  end

  def estimated_arrival(lat : Float64, lon : Float64)
    return Time.now
  end
end
