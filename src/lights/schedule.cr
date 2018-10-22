require "./command"

class Schedule
  def initialize(id, data : Hash)
    @id = id
    @name = data["name"]
    @time = data["time"]
    @status = data["status"]
    @description = data["description"]
    @local_time = data["localtime"]
    @created = data["created"]
    @command = Command.new(data["command"])
  end

  def scene
    @command.body["scene"]
  end

  def data
    data = {} of String => Any
    data["name"] = @name if @name
    data["time"] = @time if @time
    data["status"] = @status if @status
    data["description"] = @description if @description
    data["localtime"] = @local_time if @local_time
    data["created"] = @created if @created
    data["command"] = @command.data unless @command.data.empty?
    data
  end
end
