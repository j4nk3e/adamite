class Group
  include JSON::Serializable

  @[JSON::Field]
  property action : BulbState
  @[JSON::Field]
  property name : String
  @[JSON::Field]
  property lights : Array(String)
  @[JSON::Field]
  property type : String
end

class GroupState < BulbState
  include JSON::Serializable

  @[JSON::Field]
  property scene : String?
end
