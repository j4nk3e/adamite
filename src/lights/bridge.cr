require "json"

class Bridge
  include JSON::Serializable

  @[JSON::Field]
  property id : String
  @[JSON::Field]
  property internalipaddress : String
  @[JSON::Field]
  property macaddress : String?
  @[JSON::Field]
  property name : String?
end
