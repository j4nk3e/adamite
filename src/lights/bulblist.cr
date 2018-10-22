require "./bulb"
require "json"

class BulbList
  @list = [] of Bulb
  delegate :each, to: @list
  delegate :[], to: @list
  delegate :<<, to: @list

  def initialize(hash : Hash)
    hash.each_key do |key|
      @list << Bulb.new key, hash[key].as_h
    end
  end
end
