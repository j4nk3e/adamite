require "./schedule"

class ScheduleList
  def initialize(data : Hash)
    super
    data.each { |id, value| @list << Schedule.new(id, value) } if data
  end
end
