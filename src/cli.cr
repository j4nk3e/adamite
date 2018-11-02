require "cli"
require "./adamite"

class AdamiteCli < Cli::Supercommand
  command "discover", default: true

  class Discover < Cli::Command
    def run
      bridges = Adamite.discover
      bridges.each do |bridge|
        begin
          puts "Registration to #{bridge.internalipaddress}"
          register = bridge.register
          puts "Username: #{register}"
        rescue e : BridgeConnectException
          puts e.message
        end
      end
    end
  end

  abstract class Login < Cli::Command
    extend Adamite

    class Options
      string "-a", desc: "Bridge address"
      string "-u", desc: "User token"
    end

    def connection
      Bridge.new "unknown", options.a, options.u
    end
  end

  class Lights < Login
    def run
      connection.request_lights.each do |id, light|
        puts "#{id} #{light.name}"
      end
    end
  end

  class Config < Login
    def run
      config = connection.request_config
      puts config.to_pretty_json
    end
  end

  class Sensor < Login
    def run
      sensors = connection.request_sensors
      puts sensors.to_pretty_json
    end
  end

  class Scene < Login
    class Options
      string "-s", desc: "Scene to set", default: ""
    end

    def run
      if options.s.empty?
        scenes = connection.request_scenes
        puts scenes.to_pretty_json
      else
        connection.set_scene options.s
      end
    end
  end

  class Group < Login
    def run
      groups = connection.request_groups
      puts groups.to_pretty_json
    end
  end

  class Off < Login
    class Options
      string "-n", desc: "Name of the light"
    end

    def run
      connection.request_lights.each do |id, light|
        puts "#{id} #{light.name} #{light.state.to_json}"
        if light.name.starts_with? options.n
          connection.set_light_state id, LightState.new false
        end
      end
    end
  end

  class On < Off
    class Options
      string "-b", desc: "Brightness", default: "255"
    end

    def run
      connection.request_lights.each do |id, light|
        puts "#{id} #{light.name} #{light.state.to_json}"
        if light.name.starts_with? options.n
          connection.set_light_state id, LightState.new true, options.b.to_i
        end
      end
    end
  end
end

AdamiteCli.run ARGV