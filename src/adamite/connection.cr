require "crest"
require "uri"
require "json"

module Adamite::Connection
  def address
    "https://www.meethue.com"
  end

  def http
    Crest::Resource.new(address, headers: {"Content-Type" => "application/json"}, logging: false)
  end

  class Registration
    include JSON::Serializable

    @[JSON::Field]
    property error : Error?
    @[JSON::Field]
    property success : Success?
  end

  def register
    data = {"devicetype" => "AdamiteCrystal"}
    response = http["/api"].post form: data.to_json
    result = Array(Registration).from_json(response.body)
    result.each do |r|
      if e = r.error
        e.process
      elsif u = r.success
        return u.username
      end
    end
    raise "Empty response"
  end

  class Success
    include JSON::Serializable

    @[JSON::Field]
    property username : String
  end

  class Error
    include JSON::Serializable

    @[JSON::Field]
    property description : String
    @[JSON::Field]
    property type : Int32

    def process
      case type
      when 1
        raise UsernameException.new
      when 3
        raise ResourceUnavailableException.new description
      when 6
        raise ParameterUnavailableException.new description
      when 101
        raise BridgeConnectException.new
      when 403
        raise SceneLockedException.new description
      else
        raise "Unknown Error: #{description}"
      end
    end
  end

  private def get(path)
    raise UsernameException.new unless username
    response = http["/api/#{username}/#{path}"].get
    result = JSON.parse(response.body)
    if (a = result.as_a?) && (h = a.first.as_h?) && h.has_key?("error")
      Error.from_json(h.to_json).process
    end
    response.body
  end

  private def put(path, data : String)
    raise UsernameException.new unless username
    response = http["/api/#{username}/#{path}"].put form: data
    result = JSON.parse(response.body)
    if (a = result.as_a?) && (h = a.first.as_h?) && h.has_key?("error")
      Error.from_json(h.to_json).process
    end
    response.body
  end

  private def post(path, data : String)
    raise UsernameException.new unless username
    response = http["/api/#{username}/#{path}"].post form: data
    result = JSON.parse(response.body)
    if (a = result.as_a?) && (h = a.first.as_h?) && h.has_key?("error")
      Error.from_json(h.to_json).process
    end
    response.body
  end

  private def delete(path)
    raise UsernameException.new unless username
    response = http["/api/#{username}/#{path}"].delete
    result = JSON.parse(response.body)
    if (a = result.as_a?) && (h = a.first.as_h?) && h.has_key?("error")
      Error.from_json(h.to_json).process
    end
    response.body
  end
end
