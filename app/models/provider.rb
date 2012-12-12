class Provider < Organization
  belongs_to :institution, :class_name => "Organization", :foreign_key => "parent_id"
  has_many :programs, :dependent => :destroy, :foreign_key => "parent_id"
end

class Provider::ObisSimpleSerializer < Organization::ObisSimpleSerializer
  def as_json(entity, options = nil)
    h = super(entity, options)
    h['institution_id'] = entity.institution.obisid
    return h
  end

  def update_from_json(entity, h, options = { })
    provider = super(entity, h, options)
    institution = Institution.find_by_obisid(h['institution_id'])
    raise ArgumentError, "Could not find institution with obisid #{h['institution_id']}" if institution.nil?
    provider.update_attribute(:parent_id, institution.id)
    return provider
  end
end

class Provider
  include JsonSerializable
  json_serializer :obisentity, ObisEntitySerializer
  json_serializer :relationships, RelationshipsSerializer
  json_serializer :obissimple, ObisSimpleSerializer
  json_serializer :simplerelationships, ObisSimpleRelationshipsSerializer
end

