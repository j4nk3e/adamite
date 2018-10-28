class Group
  include JSON::Serializable

  @[JSON::Field]
  property action : LightState
  @[JSON::Field]
  property name : String
  @[JSON::Field]
  property lights : Array(String)
  @[JSON::Field]
  property type : String
end

class GroupState < LightState
  include JSON::Serializable

  @[JSON::Field]
  property scene : String?
end
