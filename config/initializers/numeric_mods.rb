class Numeric
  def to_radians
    self * Math::PI / 180
  end
  
  def to_degrees
    self * 180 / Math::PI
  end
end