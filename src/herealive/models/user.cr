crystal_model(
  User,
  id : (Int32 | Nil) = nil,
  email : (String | Nil) = nil,
  hashed_password : (String | Nil) = nil,
  created_at : (Time | Nil) = nil,
  updated_at : (Time | Nil) = nil,
  last_sign_in : (Time | Nil) = nil
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

      # mark last time of sign in
      user.not_nil!.update({"last_sign_in" => Time.now})
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

  def active_pings(offset = 5, time_offset = Time::Span.new(1, 0, 0))
    sql = "select * from pings where user_id = #{self.id} order by id DESC offset #{offset} limit 1;"
    result = Ping.service.execute_sql(sql)
    pings = crystal_resource_convert_ping(result)
    if pings.size > 0
      # get time and fetch
      if pings[0].created_at
        time_from = pings[0].created_at.not_nil! - time_offset
        sql = "select * from pings where user_id = #{self.id} and pings.created_at > #{time_from} order by id DESC;"
      else
        sql = "select * from pings where user_id = #{self.id} order by id DESC limit #{offset};"
      end

      result = Ping.service.execute_sql(sql)
      pings = crystal_resource_convert_ping(result)
      return pings
    else
      return pings
    end
  end

  def public
    ap = active_pings

    {
      "email" => self.email,
      "id" => self.id,
      "created_at" => self.created_at,
      "last_sign_in" => self.last_sign_in,
      "active_pings" => ap
    }
  end
end
