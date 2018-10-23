class User
  include JSON::Serializable

  @[JSON::Field]
  property name : String

  @[JSON::Field(key: "create date", converter: Time::Format.new "%Y-%m-%dT%H:%M:%S")]
  property create_date : Time

  @[JSON::Field(key: "last use date", converter: Time::Format.new "%Y-%m-%dT%H:%M:%S")]
  property last_use_date : Time
end
