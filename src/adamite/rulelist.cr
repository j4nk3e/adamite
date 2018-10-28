require "./rule"

class RuleList
  def initialize(data : Hash)
    super
    data.each { |id, value| @list << Rule.new(id, value) } if data
  end
end
