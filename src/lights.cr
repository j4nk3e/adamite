require "crest"
require "uri"
require "json"
require "cli"

require "./lights/bridge"
require "./lights/exception"
require "./lights/datastore"
require "./lights/groupstate"

module Lights
  VERSION = "0.1.0"

  class Lights
    def initialize(@address = "https://www.meethue.com", @username = "")
    end

    @bulbs = [] of Bulb
    @groups = [] of Group
    @bridges = [] of Bridge

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
      get "config"
    end

    def add_bulb(id, bulb_data)
      @bulbs << Bulb.new(id, bulb_data)
    end

    def search_new
      post "lights"
    end

    def request_bulb_list
      BulbList.new get("lights").as_h
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

    def request_config
      get "config"
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
      put "lights/#{id}/state", state.data
    end

    def set_group_state(id, state)
      put "groups/#{id}/action", state
    end

    def create_group(group)
      post "groups", group
    end

    def create_scene(scene)
      post "scenes/#{scene.id}", scene
    end

    def delete_scene(id)
      delete "scenes/#{id}"
    end

    def delete_group(id)
      delete "groups/#{id}"
    end

    def edit_bulb(bulb)
      put "lights/#{bulb.id}", bulb
    end

    def edit_group(group)
      put "groups/#{group.id}", group
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
      result
    end

    private def put(path, data : Hash)
      raise UsernameException.new unless @username
      puts data.to_json
      response = http["/api/#{@username}/#{path}"].put form: data.to_json
      result = JSON.parse(response.body)
      if (a = result.as_a?) && (h = a.first.as_h?) && h.has_key?("error")
        process_error h
      end
      result
    end

    private def post(path, data : Hash)
      raise UsernameException.new unless @username
      response = http["/api/#{@username}/#{path}"].post form: data.to_json
      result = JSON.parse(response.body)
      if (a = result.as_a?) && (h = a.first.as_h?) && h.has_key?("error")
        process_error h
      end
      result
    end

    private def delete(path)
      raise UsernameException.new unless @username
      response = http["/api/#{@username}/#{path}"].delete
      result = JSON.parse(response.body)
      if (a = result.as_a?) && (h = a.first.as_h?) && h.has_key?("error")
        process_error result.first
      end
      result
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
        lights.request_bulb_list.each do |bulb|
          puts "#{bulb.id} #{bulb.name}"
          if bulb.name == "Stehlampe"
            bulb.state.on = false
            lights.set_bulb_state bulb.id, bulb.state
          end
        end
      end
    end
  end
end

Lights::LightsCli.run ARGV
