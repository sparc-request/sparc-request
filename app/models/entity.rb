module Entity
  @entity_classes = [ ]

  class << self
    attr_reader :entity_classes
  end

  def self.included(subclass)
    @entity_classes << subclass
  end

  def assign_obisid
    if not self.obisid then
      self.obisid = generate_unique_obisid()
    end

    return true
  end

  def generate_unique_obisid
    obisid = nil

    begin
      obisid = SecureRandom.hex(16)
    end until unique_obisid?(obisid)

    return obisid
  end

  def unique_obisid?(obisid)
    return self.class.where(:obisid => obisid).length == 0
  end

  # TODO: Can't do this in a mixin, because it overrides the method
  # defined by the class in which this module is mixed-into
  # def type
  #   raise NotImplementedError, "#type not implemented for #{self.class.name}"
  # end

  def classes
    return [ type().downcase ]
  end
end
