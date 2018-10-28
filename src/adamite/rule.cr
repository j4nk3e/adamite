class Rule
  def initialize(id : String, data : Hash = nil)
    @id = id
    @name = data["name"]
    @owner = data["owner"]
    @created = data["created"]
    @last_triggered = data["lasttriggered"]
    @times_triggered = data["timestriggered"]
    @status = data["status"]
    @conditions = data["conditions"]
    @actions = data["actions"]
  end

  def data
    data = {} of String => HObject
    data["name"] = @name if @name
    data["owner"] = @owner if @owner
    data["created"] = @created if @created
    data["lasttriggered"] = @last_triggered if @last_triggered
    data["timestriggered"] = @times_triggered if @times_triggered
    data["status"] = @status if @status
    data["conditions"] = @conditions if @conditions
    data["actions"] = @actions if @actions
    data
  end
end
