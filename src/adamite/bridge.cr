require "json"
require "./connection"

class Bridge
  include JSON::Serializable
  include Adamite::Connection

  @[JSON::Field]
  property id : String
  @[JSON::Field]
  property internalipaddress : String
  @[JSON::Field]
  property macaddress : String?
  @[JSON::Field]
  property name : String?

  @user : User?
  @config : HueConfig?
  @lights = {} of String => Light
  @groups = {} of String => Group
  @scenes = {} of String => Scene
  @sensors = {} of String => Sensor

  def address
    "http://#{@internalipaddress}"
  end

  def username
    @user.try &.name
  end

  def initialize(@internalipaddress, name : String)
    @id = "unknown"
    @user = User.new name
  end
end
