require "./user"

class UserList
  def initialize(data : Hash)
    super
    data.each { |id, value| @list << User.new(id, value) } if data
  end
end
