class Scene
  def initialize(id : String, data : Hash = nil)
    @id = id
    @name = data["name"]
    @active = data["active"]
    @lights = data["lights"]
    @recycle = data["recycle"]
    @transition_time = data["transitiontime"]
  end

  def data
    data = {} of String => Any
    data["name"] = @name if @name
    data["active"] = @active unless @active.nil?
    data["lights"] = @lights if @lights
    data["recycle"] = @recycle unless @recycle.nil?
    data["transitiontime"] = @transition_time if @transition_time
    data
  end
end
