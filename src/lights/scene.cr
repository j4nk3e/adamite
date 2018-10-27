class Scene
  include JSON::Serializable

  @[JSON::Field]
  property name : String

  @[JSON::Field]
  property active : Bool?

  @[JSON::Field]
  property lights : Array(String)

  @[JSON::Field]
  property recycle : Bool

  @[JSON::Field]
  property transitiontime : Int64?
end

class SetScene
  include JSON::Serializable

  @[JSON::Field]
  property scene : String

  def initialize(@scene : String)
  end
end
