class Group
  def initialize(id : String, data : Hash = nil)
    @id = id
    @action = BulbState.new(data["action"])
    @name = data["name"]
    @lights = data["lights"]
    @type = data["type"]
  end

  def data
    data = {} of String => Any
    data["name"] = @name if @name
    data["lights"] = @lights if @lights
    data["type"] = @type if @type
    data["action"] = @action.data unless @action.data.empty?
    data
  end
end
