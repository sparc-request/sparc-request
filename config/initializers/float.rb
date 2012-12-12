class Float
  def floor_to(x)
    (self * 10**x).floor.to_f / 10**x
  end
end
