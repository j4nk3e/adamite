class BulbState
  MAX_CT              =   500
  MIN_CT              =   153
  MAX_BRI             =   255
  MIN_BRI             =     0
  MAX_SAT             =   255
  MIN_SAT             =     0
  MAX_HUE             = 65535
  MIN_HUE             =     0
  MIN_TRANSITION_TIME =     0
  MAX_XY              =   1.0
  MIN_XY              =   0.0

  module Effect
    NONE      = "none"
    COLORLOOP = "colorloop"
  end

  module Alert
    NONE    = "none"
    SELECT  = "select"
    LSELECT = "lselect"
  end

  module ColorMode
    HS = "hs"
    XY = "xy"
    CT = "ct"
  end

  module Hue
    YELLOW = 12750
    LGREEN = 22500
    GREEN  = 25500
    BLUE   = 46920
    PURPLE = 56100
    RED    = 65535
  end

  @on = false
  @bri : Int32?
  @ct : Int32?
  @xy = [] of Float64
  @hue : Int32?
  @sat : Int32?
  @transition_time : Int32?
  @alert : String?
  @color_mode : String?
  @effect : String?
  @reachable = false

  def initialize(data : Hash(String, JSON::Any))
    data = {} of String => JSON::Any if data == nil
    @reachable = data["reachable"].as_bool

    # bridge returns invaild values for state variables when reachable is false
    unless @reachable == false
      @on = data["on"]?.try &.as_bool? || false
      set_bri data["bri"]?.try &.as_i?
      set_hue data["hue"]?.try &.as_i?
      set_sat data["sat"]?.try &.as_i?
      set_xy data["xy"]?.try &.as_a?
      set_ct data["ct"]?.try &.as_i?
      set_alert data["alert"]?.try &.as_s?
      set_effect data["effect"]?.try &.as_s?
      set_color_mode data["colormode"]?.try &.as_s?
      set_transition_time data["transitiontime"]?.try &.as_i?
    end
  end

  def color_mode=(value)
    set_color_mode(value)
  end

  def set_color_mode(value)
    if value.nil? || value == ColorMode::XY || value == ColorMode::HS || value == ColorMode::CT
      @color_mode = value
    else
      raise BulbStateValueTypeException.new "Color mode value has incorrect type. Requires 'hs', 'xy', or 'ct'. Was #{value.inspect}"
    end
  end

  def alert=(value)
    set_alert(value)
  end

  def set_alert(value)
    if value.nil? || value == Alert::NONE || value == Alert::SELECT || value == Alert::LSELECT
      @alert = value
    else
      raise BulbStateValueTypeException.new "Alert value has incorrect type. Requires 'none', 'select', or 'lselect'. Was #{value.inspect}"
    end
  end

  def effect=(value)
    set_effect(value)
  end

  def set_effect(value)
    if value.nil? || value == Effect::NONE || value == Effect::COLORLOOP
      @effect = value
    else
      raise BulbStateValueTypeException.new "Effect value has incorrect type. Requires 'none' or 'colorloop'. Was #{value.inspect}"
    end
  end

  def on=(value)
    set_on(value)
  end

  def set_on(value)
    # Tests if value is boolean
    if !!value == value
      @on = value
    else
      raise BulbStateValueTypeException.new "On value has incorrect type. Requires boolean, got #{value.class}. Was #{value.inspect}"
    end
  end

  def bri=(value)
    set_bri(value)
  end

  def set_bri(value)
    if value.nil? || (MIN_BRI..MAX_BRI).includes? value
      @bri = value
    else
      raise BulbStateValueOutOfRangeException.new "Brightness value out of range. Must be [#{MIN_BRI},#{MAX_BRI}]. Was #{value.inspect}"
    end
  end

  def ct=(value)
    set_ct(value)
  end

  def set_ct(value)
    if !value.nil? && (!value.is_a? Int)
      raise BulbStateValueTypeException.new "Color temperature value has incorrect type. Requires integer, got #{value.class}"
    elsif value.nil? || (MIN_CT..MAX_CT).includes? value
      @ct = value
    else
      raise BulbStateValueOutOfRangeException.new "Color temperature value out of range. Must be [#{MIN_CT},#{MAX_CT}]. Was #{value.inspect}"
    end
  end

  def sat=(value)
    set_sat(value)
  end

  def set_sat(value)
    if !value.nil? && (!value.is_a? Int)
      raise BulbStateValueTypeException.new "Saturation value has incorrect type. Requires integer, got #{value.class}"
    elsif value.nil? || (MIN_SAT..MAX_SAT).includes? value
      @sat = value
    else
      raise BulbStateValueOutOfRangeException.new "Saturation alue out of range. Must be [#{MIN_SAT},#{MAX_SAT}]. Was #{value.inspect}"
    end
  end

  def hue=(value)
    set_hue(value)
  end

  def set_hue(value)
    if !value.nil? && (!value.is_a? Int)
      raise BulbStateValueTypeException.new "Hue value has incorrect type. Requires integer, got #{value.class}"
    elsif value.nil? || (MIN_HUE..MAX_HUE).includes? value
      @hue = value
    else
      raise BulbStateValueOutOfRangeException.new "Hue value out of range. Must be [#{MIN_HUE},#{MAX_HUE}]. Was #{value.inspect}"
    end
  end

  def transition_time=(value)
    set_transition_time(value)
  end

  def set_transition_time(value)
    if !value.nil? && (!value.is_a? Float)
      raise BulbStateValueTypeException.new "Transition time value has incorrect type. Requires decimal, got #{value.class}"
    elsif value.nil? || value >= MIN_TRANSITION_TIME
      @transition_time = value
    else
      raise BulbStateValueOutOfRangeException.new "Transition time value out of range. Must be > #{MIN_TRANSITION_TIME}. Was #{value.inspect}"
    end
  end

  def xy=(value)
    set_xy(value)
  end

  def set_xy(value)
    if !value.nil? && (!value.is_a? Array)
      raise BulbStateValueTypeException.new "XY value has incorrect type. Requires array, got #{value.class}"
    elsif value.nil?
      return
    elsif value.size == 2 && value[0].as_f >= MIN_XY && value[0].as_f <= MAX_XY && value[1].as_f >= MIN_XY && value[1].as_f <= MAX_XY
      @xy.clear
      @xy << value[0].as_f
      @xy << value[1].as_f
    else
      raise BulbStateValueOutOfRangeException.new "XY value out of range. Must be [#{MIN_XY},#{MAX_XY}]. Was #{value.inspect}"
    end
  end

  def data
    data = {} of String => JSON::Any
    data["on"] = @on unless @on.nil?
    data["bri"] = @bri if @bri
    data["hue"] = @hue if @hue
    data["sat"] = @sat if @sat
    data["xy"] = @xy if @xy
    data["ct"] = @ct if @ct
    data["alert"] = @alert if @alert
    data["effect"] = @effect if @effect
    data["colormode"] = @color_mode if @color_mode
    data["reachable"] = @reachable unless @reachable.nil?
    data["transitiontime"] = @transition_time if @transition_time
    data
  end
end
