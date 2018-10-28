class SensorState
  include JSON::Serializable

  @[JSON::Field(key: "last use date", converter: Time::Format.new "%Y-%m-%dT%H:%M:%S")]
  property last_updated : Time?
  @[JSON::Field]
  property daylight : Bool?
  @[JSON::Field]
  property buttonevent : Int32?
end

class Sensor
  include JSON::Serializable

  @[JSON::Field]
  property name : String?
  @[JSON::Field]
  property type : String?
  @[JSON::Field]
  property modelid : String?
  @[JSON::Field]
  property manufacturername : String?
  @[JSON::Field]
  property uniqueid : String?
  @[JSON::Field]
  property swversion : String?
  @[JSON::Field]
  property config : JSON::Any
  @[JSON::Field]
  property state : SensorState?
end
