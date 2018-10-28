require "./user"

class HueConfig
  include JSON::Serializable

  @[JSON::Field]
  property name : String?
  @[JSON::Field]
  property zigbeechannel : Int32?
  @[JSON::Field]
  property mac : String?
  @[JSON::Field]
  property dhcp : Bool?
  @[JSON::Field]
  property ipaddress : String?
  @[JSON::Field]
  property netmask : String?
  @[JSON::Field]
  property gateway : String?
  @[JSON::Field]
  property proxyaddress : String?
  @[JSON::Field]
  property proxyport : Int32?
  @[JSON::Field]
  property utc : String?
  @[JSON::Field(converter: Time::Format.new "%Y-%m-%dT%H:%M:%S")]
  property localtime : Time?
  @[JSON::Field]
  property timezone : String?
  @[JSON::Field]
  property whitelist : Hash(String, User)?
  @[JSON::Field]
  property swversion : JSON::Any
  @[JSON::Field]
  property apiversion : String?
  @[JSON::Field]
  property swupdate : JSON::Any
  @[JSON::Field]
  property linkbutton : Bool?
  @[JSON::Field]
  property portalservices : Bool?
  @[JSON::Field]
  property portalconnection : String?
  @[JSON::Field]
  property portalstate : JSON::Any
end
