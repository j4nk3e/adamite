require "./bulbstate"

class Bulb
  getter id : String
  getter name : String
  getter type : String
  getter sw_version : String
  getter model_id : String
  getter unique_id : String
  getter state : BulbState

  def initialize(@id : String, data : Hash(String, JSON::Any))
    @name = data["name"].as_s
    @type = data["type"].as_s
    @sw_version = data["swversion"].as_s
    @model_id = data["modelid"].as_s
    @unique_id = data["uniqueid"].as_s
    @state = BulbState.new data["state"].as_h
  end

  def data
    data = {} of String => Any
    data["name"] = @name if @name
    data["type"] = @type if @type
    data["swversion"] = @sw_version if @sw_version
    data["state"] = @state.data unless @state.data.empty?
    data["modelid"] = @model_id if @model_id
    data["uniqueid"] = @unique_id if @unique_id
    data
  end
end
