require "./scene"

class SceneList
  def initialize(data : Hash)
    super
    data.each { |id, value| @list << Scene.new(id, value) } if data
  end
end
