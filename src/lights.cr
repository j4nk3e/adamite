require "crest"
require "uri"
require "json"
require "cli"

require "./lights/bridge"
require "./lights/bulb"
require "./lights/config"
require "./lights/exception"
require "./lights/groupstate"
require "./lights/group"

# @lights = BulbList.new(data["lights"])
# @groups = GroupList.new(data["groups"])
# @config = HueConfig.new(data["config"])
# @schedules = ScheduleList.new(data["schedules"])
# @scenes = SceneList.new(data["scenes"])
# @rules = RuleList.new(data["rules"])
# @sensors = SensorList.new(data["sensors"])

module Lights
  VERSION = "0.1.0"

  class Lights
    def initialize(@address = "https://www.meethue.com", @username = "")
      @bulbs = {} of String => Bulb
      @groups = [] of Group
      @bridges = [] of Bridge
    end

    def http
      Crest::Resource.new(@address, headers: {"Content-Type" => "application/json"}, logging: false)
    end

    def discover_hubs
      puts "Discovering hubs"
      response = http["/api/nupnp"].get

      case response.status_code.to_i
      when 200
        @bridges = Array(Bridge).from_json(response.body)
      else
        raise "Unknown error"
      end
      @bridges
    end

    def register
      data = {"devicetype" => "lights"}
      response = http["/api"].post form: data.to_json
      result = JSON.parse(response.body).as_a
      result.each do |r|
        if r.as_h.has_key? "error"
          process_error r
        elsif s = r["success"]
          @username = s["username"].as_s
        end
      end
      @username
    end

    def request_config
      HueConfig.from_json get("config")
    end

    def add_bulb(id, bulb_data)
      @bulbs[id] = Bulb.from_json bulb_data
    end

    def search_new
      post "lights"
    end

    def request_bulb_list
      Hash(String, Bulb).from_json get("lights")
    end

    def request_new_bulb_list
      get "lights/new"
    end

    def request_new_sensor_list
      get "sensors/new"
    end

    def request_bulb_info(id)
      response = get "lights/#{id}"
      Bulb.new(id, response)
    end

    def request_group_info(id)
      response = get "groups/#{id}"
      Group.new(id, response)
    end

    def request_sensor_info(id)
      response = get "sensors/#{id}"
      Sensor.new(id, response)
    end

    def request_sensor_list
      get "sensors"
    end

    def request_group_list
      get "groups"
    end

    def request_schedule_list
      get "schedules"
    end

    def request_scene_list
      get "scenes"
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

    def set_bulb_state(id, state)
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

    def edit_bulb(bulb)
      put "lights/#{bulb.id}", bulb.to_json
    end

    def edit_group(group)
      put "groups/#{group.id}", group.to_json
    end

    def delete_user(username)
      delete "config/whitelist/#{username}"
    end

    private def process_error(result)
      type = result["error"]["type"].as_i
      case type
      when 1
        raise UsernameException.new
      when 3
        raise ResourceUnavailableException.new result["error"]["description"].as_s
      when 6
        raise ParameterUnavailableException.new result["error"]["description"].as_s
      when 101
        raise BridgeConnectException.new
      when 403
        raise SceneLockedException.new result["error"]["description"].as_s
      else
        raise "Unknown Error: #{result["error"]["description"]}"
      end
    end

    private def get(path)
      raise UsernameException.new unless @username
      response = http["/api/#{@username}/#{path}"].get
      result = JSON.parse(response.body)
      if (a = result.as_a?) && (h = a.first.as_h?) && h.has_key?("error")
        process_error h
      end
      response.body
    end

    private def put(path, data : String)
      raise UsernameException.new unless @username
      response = http["/api/#{@username}/#{path}"].put form: data
      result = JSON.parse(response.body)
      if (a = result.as_a?) && (h = a.first.as_h?) && h.has_key?("error")
        process_error h
      end
      response.body
    end

    private def post(path, data : String)
      raise UsernameException.new unless @username
      response = http["/api/#{@username}/#{path}"].post form: data
      result = JSON.parse(response.body)
      if (a = result.as_a?) && (h = a.first.as_h?) && h.has_key?("error")
        process_error h
      end
      response.body
    end

    private def delete(path)
      raise UsernameException.new unless @username
      response = http["/api/#{@username}/#{path}"].delete
      result = JSON.parse(response.body)
      if (a = result.as_a?) && (h = a.first.as_h?) && h.has_key?("error")
        process_error result.first
      end
      response.body
    end
  end

  abstract class Login < Cli::Command
    class Options
      string "-a", desc: "Bridge address"
      string "-u", desc: "User token"
    end

    def lights
      Lights.new "http://#{options.a}", options.u
    end
  end

  class LightsCli < Cli::Supercommand
    command "discover", default: true

    class Discover < Cli::Command
      def run
        discover = Lights.new.discover_hubs
        if discover.size == 1
          begin
            register = Lights.new("http://#{discover.first.internalipaddress}").register
            puts "Username: #{register}"
          rescue e : BridgeConnectException
            puts e.message
          end
        end
      end
    end

    class List < Login
      def run
        lights.request_bulb_list.each do |id, bulb|
          puts "#{id} #{bulb.name}"
        end
      end
    end

    class Config < Login
      def run
        config = lights.request_config
        puts config.to_pretty_json
      end
    end

    class Off < Login
      class Options
        string "-n", desc: "Name of the light"
      end

      def run
        lights.request_bulb_list.each do |id, bulb|
          puts "#{id} #{bulb.name} #{bulb.state.to_json}"
          if bulb.name.starts_with? options.n
            lights.set_bulb_state id, BulbState.new false
          end
        end
      end
    end

    class On < Off
      class Options
        string "-b", desc: "Brightness", default: "255"
      end

      def run
        lights.request_bulb_list.each do |id, bulb|
          puts "#{id} #{bulb.name} #{bulb.state.to_json}"
          if bulb.name.starts_with? options.n
            lights.set_bulb_state id, BulbState.new true, options.b.to_i
          end
        end
      end
    end
  end
end

Lights::LightsCli.run ARGV
