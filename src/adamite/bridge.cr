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

  def initialize(@id, @internalipaddress, name : String)
    @user = User.new name
  end

  def set_scene(id)
    set_group_state(0, SetScene.new id)
  end

  def request_config
    @config = HueConfig.from_json get("config")
  end

  def add_light(id, light_data)
    @lights[id] = Light.from_json light_data
  end

  def search_new
    post "lights"
  end

  def request_lights
    @lights = Hash(String, Light).from_json get("lights")
  end

  def request_new_lights
    get "lights/new"
  end

  def request_new_sensors
    get "sensors/new"
  end

  def request_light_info(id)
    Light.from_json get("lights/#{id}")
  end

  def request_group_info(id)
    Group.from_json get("groups/#{id}")
  end

  def request_sensor_info(id)
    Sensor.from_json get("sensors/#{id}")
  end

  def request_sensors
    @sensors = Hash(String, Sensor).from_json get("sensors")
  end

  def request_groups
    @groups = Hash(String, Group).from_json get("groups")
  end

  def request_schedules
    get "schedules"
  end

  def request_scenes
    @scenes = Hash(String, Scene).from_json get("scenes")
  end

  def request_rules
    get "rules"
  end

  def request_schedules
    get "schedules"
  end

  def request_datastore
    get ""
  end

  def set_light_state(id, state)
    put "lights/#{id}/state", state.to_json
  end

  def set_group_state(id, state)
    put "groups/#{id}/action", state.to_json
  end

  def create_group(group)
    post "groups", group.to_json
  end

  def create_scene(scene)
    post "scenes/#{scene.id}", scene.to_json
  end

  def delete_scene(id)
    delete "scenes/#{id}"
  end

  def delete_group(id)
    delete "groups/#{id}"
  end

  def edit_light(light)
    put "lights/#{light.id}", light.to_json
  end

  def edit_group(group)
    put "groups/#{group.id}", group.to_json
  end

  def delete_user(username)
    delete "config/whitelist/#{username}"
  end
end
