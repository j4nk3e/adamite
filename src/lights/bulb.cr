require "./bulbstate"

class Bulb
  include JSON::Serializable

  @[JSON::Field]
  getter name : String
  @[JSON::Field]
  getter type : String
  @[JSON::Field]
  getter swversion : String
  @[JSON::Field]
  getter modelid : String
  @[JSON::Field]
  getter uniqueid : String
  @[JSON::Field]
  getter state : BulbState
end
