require "./group"

class GroupList
  def initialize(data : Hash)
    super
    data.each { |id, value| @list << Group.new(id, value) } if data
  end
end
