class Core
  include JsonSerializable
  json_serializer :obisentity, Organization::ObisEntitySerializer
  json_serializer :relationships, Core::RelationshipsSerializer
end

