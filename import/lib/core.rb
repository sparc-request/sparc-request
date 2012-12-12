class Core::ObisSimpleSerializer < Organization::ObisSimpleSerializer
  def as_json(entity, options = nil)
    h = super(entity, options)
    h['program_id'] = entity.program.try(:obisid)
    return h
  end

  def update_from_json(entity, h, options = { })
    core = super(entity, h, options)
    program = Program.find_by_obisid(h['program_id'])
    raise ArgumentError, "Could not find program with obisid #{h['program_id']}" if program.nil?
    core.update_attribute(:parent_id, program.id)
    return core
  end
end

class Core
  include JsonSerializable
  json_serializer :obisentity, Organization::ObisEntitySerializer
  json_serializer :relationships, Core::RelationshipsSerializer
  json_serializer :obissimple, Core::ObisSimpleSerializer
  json_serializer :simplerelationships, ObisSimpleRelationshipsSerializer
end

