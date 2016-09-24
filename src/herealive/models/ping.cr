crystal_model(
  Ping,
  id : (Int32 | Nil) = nil,
  user_id : (Int32 | Nil) = nil,
  lat : (Float64 | Nil) = nil,
  lon : (Float64 | Nil) = nil,
  created_at : (Time | Nil) = nil,
  updated_at : (Time | Nil) = nil,
  manually : (Bool | Nil) = nil,
  accuracy : (Int32 | Nil) = nil,
  altitude : (Int32 | Nil) = nil,
  altitudeAccuracy : (Int32 | Nil) = nil,
  heading : (Int32 | Nil) = nil,
  location : (String | Nil) = nil,
  speed : (Int32 | Nil) = nil,
  source : (String | Nil) = nil,
)
crystal_resource(ping, pings, Ping)
