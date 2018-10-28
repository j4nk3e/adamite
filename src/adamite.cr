require "./adamite/connection"
require "./adamite/bridge"
require "./adamite/light"
require "./adamite/config"
require "./adamite/exception"
require "./adamite/group"
require "./adamite/scene"
require "./adamite/sensor"

module Adamite
  extend Adamite::Connection
  VERSION = "0.1.0"

  def self.discover
    puts "Discovering bridges"
    response = http["/api/nupnp"].get

    case response.status_code.to_i
    when 200
      bridges = Array(Bridge).from_json(response.body)
    else
      raise "Unknown error"
    end
    bridges
  end
end
