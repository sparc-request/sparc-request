require 'pp'

# TODO: not sure why I need comparators for TrueClass and FalseClass
class FalseClass
  def <=>(other)
    if other == true then
      return 1
    elsif other == false then
      return 0
    else
      return 1
    end
  end
end

class TrueClass
  def <=>(other)
    if other == false then
      return -1
    elsif other == true then
      return 0
    else
      return 1
    end
  end
end

class NilClass
  def <=>(other)
    if other == nil then
      return 0
    else
      return 1
    end
  end
end

class Hash
  def <=>(other)
    result = self.sort <=> other.sort
    return result
  end
end

class Object
  def compare(other)
    fail "#{self.pretty_inspect} != #{other.pretty_inspect}" if self != other
  end
end

class Array
  def compare(other)
    begin
      if self.class != other.class then
        fail "Cannot compare #{self.class} to #{other.class}"
      end

      if self.length != other.length then
        fail "Sizes of #{self.pretty_inspect} and #{other.pretty_inspect} differ (#{self.length} != #{other.length})"
      end

      if self != other then
        self.each_with_index do |value, idx|
          begin
            value.compare(other[idx])
          rescue
            fail "at index #{idx}:\n#{$!.message}"
          end
        end
      end
    rescue
      fail "While comparing:\n #{self.pretty_inspect}with:\n #{other.pretty_inspect}:\n#{$!.message}"
    end
  end
end

class Hash
  def missing_keys(other)
    return (self.keys - other.keys).sort
  end

  def missing_key_values(other)
    keys = missing_keys(other)
    key_values = keys.map { |key| "#{key.inspect}=#{self[key].inspect}" }
    s = key_values.join(', ')
    return s
  end

  def compare(other)
    begin
      if self.class != other.class then
        fail "Cannot compare #{self.class} to #{other.class}"
      end

      if self.keys.sort != other.keys.sort then
        fail "Hash keys differ (one has #{self.missing_key_values(other)} and the other has #{other.missing_key_values(self)})"
      end

      self.each do |key, value|
        begin
          value.compare(other[key])
        rescue
          fail "in key #{key.pretty_inspect}, #{$!.message}"
        end
      end
    rescue
      fail "While comparing:\n #{self.pretty_inspect}with:\n #{other.pretty_inspect}:\n#{$!.message}"
    end
  end
end

