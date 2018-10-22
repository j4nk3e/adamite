require "./bulbstate"

class GroupState < BulbState
  def initialize(data : Hash)
    super(data)
    set_scene data["scene"] if data["scene"]
  end

  def scene=(value)
    set_scene(value)
  end

  def set_scene(value)
    if value.class == String
      @scene = value
    else
      raise BulbStateValueTypeException, "Scene value has incorrect type. Requires String, got #{value.class}. Was #{value.inspect}"
    end
  end

  def data
    data = BulbState.instance_method(:data).bind(self).call
    data["scene"] = @scene if @scene
    data
  end
end
