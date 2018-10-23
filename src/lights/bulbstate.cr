class BulbState
  include JSON::Serializable

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

  @[JSON::Field]
  property on : Bool
  @[JSON::Field]
  property bri : Int32?
  @[JSON::Field]
  property ct : Int32?
  @[JSON::Field]
  property xy : Array(Float64)?
  @[JSON::Field]
  property hue : Int32?
  @[JSON::Field]
  property sat : Int32?
  @[JSON::Field]
  property transition_time : Int32?
  @[JSON::Field]
  property alert : String?
  @[JSON::Field]
  property color_mode : String?
  @[JSON::Field]
  property effect : String?
  @[JSON::Field]
  property reachable : Bool?

  def initialize(parser)
    @on = false
    self.initialize parser
  end

  def initialize(@on : Bool)
  end

  def initialize(@on : Bool, @bri : Int32)
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
end
