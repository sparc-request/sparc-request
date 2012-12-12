class Program < Organization
  include Entity

  belongs_to :provider, :class_name => "Organization", :foreign_key => "parent_id"
  has_many :cores, :dependent => :destroy, :foreign_key => "parent_id"
  has_many :services, :dependent => :destroy, :foreign_key => "organization_id"
end

class Program::ObisSimpleSerializer < Organization::ObisSimpleSerializer
  def as_json(entity, options = nil)
    h = super(entity, options)
    h['provider_id'] = entity.provider.try(:obisid)
    return h
  end

  def update_from_json(entity, h, options = { })
    program = super(entity, h, options)
    provider = Provider.find_by_obisid(h['provider_id'])
    raise ArgumentError, "Could not find provider with obisid #{h['provider_id']}" if provider.nil?
    program.update_attribute(:parent_id, provider.id)
    return program
  end
end

class Program
  include JsonSerializable
  json_serializer :obisentity, ObisEntitySerializer
  json_serializer :relationships, RelationshipsSerializer
  json_serializer :obissimple, ObisSimpleSerializer
  json_serializer :simplerelationships, ObisSimpleRelationshipsSerializer
end

