class Project < Protocol
  include JsonSerializable
  json_serializer :obisentity, Protocol::ObisEntitySerializer
  json_serializer :relationships, Protocol::RelationshipsSerializer
end

