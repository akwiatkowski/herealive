crystal_model(
  Ping,
  id : (Int32 | Nil) = nil,
  user_id : (Int32 | Nil) = nil,
  lat : (Float64 | Nil) = nil,
  lon : (Float64 | Nil) = nil,
  created_at : (Time | Nil) = nil,
  updated_at : (Time | Nil) = nil,
  manually : (Bool | Nil) = nil
)
crystal_resource(ping, pings, Ping)
