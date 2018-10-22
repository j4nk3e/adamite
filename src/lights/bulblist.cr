require "./bulb"
require "json"

class BulbList
  @list = [] of Bulb

  def initialize(hash : Hash)
    hash.each_key do |key|
      Bulb.new key, hash[key].as_h
    end
  end
end
