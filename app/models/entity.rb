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

# Serializer base class for "entities" on the obisentity query.
class Entity::ObisEntitySerializer
  def as_json(entity, options = nil)
    attributes = { }

    h = {
      '_id'         => entity.obisid,
      'type'        => 'entity',
      'classes'     => entity.classes(),

      'identifiers' => {
        'OBISID'       => entity.obisid,
      },

      'attributes'   => attributes,
    }

    h['created_at'] = entity.created_at.utc.strftime('%F %T %Z') if entity.created_at
    h['updated_at'] = entity.updated_at.utc.strftime('%F %T %Z') if entity.updated_at

    return h
  end

  def self.create_from_json(entity_class, h, options = nil)
    obj = entity_class.create()
    obj.update_from_json(h, options)
    return obj
  end

  # This method is defined in the base class in order to ensure that
  # timestamps are always updated _after_ all the other attributes have
  # already been updated.  Do not override this method from the derived
  # class; this will result in incorrect behavior.
  def update_from_json(entity, h, options = nil)
    # First call update_attributes_from_json to update the model's
    # normal attributes.
    update_attributes_from_json(entity, h, options)

    # Lastly, call update_timestamps_from_json to update the model's
    # timestamps, if the appropriate override attributes are specified.
    update_timestamps_from_json(entity, h, options)

    return entity
  end

  def update_attributes_from_json(entity, h, options = nil)
    if h['override_obisid'] then
      entity.update_attribute(:obisid, h['identifiers']['OBISID'])
    end
  end

  def update_timestamps_from_json(entity, h, options = nil)
    # TODO: not thread-safe
    orig_record_timestamps = entity.class.record_timestamps
    entity.class.record_timestamps = false
    begin
      if h['override_created_at'] and h['created_at'] then
        entity.update_attribute(:created_at, Time.parse(h['created_at']))
      end

      if h['override_updated_at'] and h['updated_at'] then
        entity.update_attribute(:updated_at, Time.parse(h['updated_at']))
      end
    ensure
      entity.class.record_timestamps = orig_record_timestamps
    end
  end

  def destroy_using_json(entity, h, opts)
    entity.destroy()
    return entity.to_json(opts)
  end
end

# Methods for "simplifying" and "unsimplifiying" a Hash.
#
# An "unsimplified" Hash looks like this:
#
#   {
#     "identifiers" => {
#       "OBISID"     => "0966f035fc7b1212f82c4c9c7a077d32"
#     },
#     "attributes" => {
#       "first_name" => "Foo",
#       "last_name"  => "Bar"
#     }
#   }
#
# A simplified version of this Hash will:
#
#   - Have the "identifiers" and "attributes" sub-hashes merged into a
#     single Hash, and
#   - Have the "OBISID" identifier changed to have a key of "id"
#
# thus the resulting simplified Hash will look like this:
#
#   {
#     "id"         => "0966f035fc7b1212f82c4c9c7a077d32",
#     "first_name" => "Foo",
#     "last_name"  => "Bar"
#   }
#
module Simplification
  def simplify(h)
    # First, get the attributes
    ob = h['attributes'].clone                                                        

    # Next, put the obisid into the attributes
    ob['id'] = h['identifiers']['OBISID']                                             

    # Now return the structure
    return ob
  end

  def unsimplify(h)
    h = h.clone

    id = h.delete('id')
    override_obisid = h.delete('override_obisid')
    override_created_at = h.delete('override_created_at')
    override_updated_at = h.delete('override_created_at')

    return {
      'identifiers' => {
        'OBISID'             => id,
      },
      'attributes'           => h,
      'override_obisid'      => override_obisid,
      'override_created_at'  => override_created_at,
      'override_updated_at'  => override_updated_at,
    }
  end
end

# Serializer base class for obissimple queries.
class Entity::ObisSimpleSerializer
  include Simplification

  def as_json(entity, options = { })
    options = options.clone
    options[:jsontype] = :obisentity
    h = entity.as_json(options)
    return simplify(h)
  end

  def self.create_from_json(entity_class, h, options = nil)
    obj = entity_class.create()
    result = obj.update_from_json(h, options)
    return result
  end

  def update_from_json(entity, h, options = { })
    options = options.clone
    options[:jsontype] = :obisentity
    h = unsimplify(h)
    result = entity.update_from_json(h, options)
    return result
  end

  def destroy_using_json(entity, h, opts)
    entity.destroy()
    result = entity.to_json(opts)
    return result
  end
end

# Serializer base class for obissimple relationships queries.
class Entity::ObisSimpleRelationshipsSerializer
  include Simplification

  def as_json(entity, options = { })
    options = options.clone
    options[:jsontype] = :relationships
    h = entity.as_json(options)
    return simplify(h)
  end

  def update_from_json(entity, h, options = { })
    options = options.clone
    options[:jsontype] = :relationships
    h = unsimplify(h)
    result = entity.update_from_json(h, options)
    return result
  end
end

