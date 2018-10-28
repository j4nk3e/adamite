require "crest"
require "uri"
require "json"

module Adamite::Connection
  def address
    "https://www.meethue.com"
  end

  def http
    Crest::Resource.new(address, headers: {"Content-Type" => "application/json"}, logging: false)
  end

  class Registration
    include JSON::Serializable

    @[JSON::Field]
    property error : Error?
    @[JSON::Field]
    property success : User?
  end

  def register
    data = {"devicetype" => "AdamiteCrystal"}
    response = http["/api"].post form: data.to_json
    result = Array(Registration).from_json(response.body)
    result.each do |r|
      if e = r.error
        e.process
      elsif u = r.success
        return u
      end
    end
  end

  class Error
    include JSON::Serializable

    @[JSON::Field]
    property description : String
    @[JSON::Field]
    property type : Int32

    def process
      case type
      when 1
        raise UsernameException.new
      when 3
        raise ResourceUnavailableException.new description
      when 6
        raise ParameterUnavailableException.new description
      when 101
        raise BridgeConnectException.new
      when 403
        raise SceneLockedException.new description
      else
        raise "Unknown Error: #{description}"
      end
    end
  end

  private def get(path)
    raise UsernameException.new unless username
    response = http["/api/#{username}/#{path}"].get
    result = JSON.parse(response.body)
    if (a = result.as_a?) && (h = a.first.as_h?) && h.has_key?("error")
      Error.from_json(h.to_json).process
    end
    response.body
  end

  private def put(path, data : String)
    raise UsernameException.new unless username
    response = http["/api/#{username}/#{path}"].put form: data
    result = JSON.parse(response.body)
    if (a = result.as_a?) && (h = a.first.as_h?) && h.has_key?("error")
      Error.from_json(h.to_json).process
    end
    response.body
  end

  private def post(path, data : String)
    raise UsernameException.new unless username
    response = http["/api/#{username}/#{path}"].post form: data
    result = JSON.parse(response.body)
    if (a = result.as_a?) && (h = a.first.as_h?) && h.has_key?("error")
      Error.from_json(h.to_json).process
    end
    response.body
  end

  private def delete(path)
    raise UsernameException.new unless username
    response = http["/api/#{username}/#{path}"].delete
    result = JSON.parse(response.body)
    if (a = result.as_a?) && (h = a.first.as_h?) && h.has_key?("error")
      Error.from_json(h.to_json).process
    end
    response.body
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
