class Command
  def initialize(data : Hash)
    @address = data["address"]
    @body = data["body"]
    @method = data["method"]
  end

  def data
    data = {} of String => Any
    data["address"] = @address if @address
    data["body"] = @body if @body
    data["method"] = @method if @method
    data
  end
end
