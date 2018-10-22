require "./sensor"

class SensorList
  def initialize(data : Hash)
    super
    data.each { |id, value| @list << Sensor.new(id, value) } if data
  end
end
