class Program
  include JsonSerializable
  json_serializer :obisentity, ObisEntitySerializer
  json_serializer :relationships, RelationshipsSerializer
end

