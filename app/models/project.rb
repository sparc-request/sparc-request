class Project < Protocol
end

class Project
  include JsonSerializable
  json_serializer :obisentity, Protocol::ObisEntitySerializer
  json_serializer :relationships, Protocol::RelationshipsSerializer
  json_serializer :obissimple, ObisSimpleSerializer
  json_serializer :simplerelationships, ObisSimpleRelationshipsSerializer
end

