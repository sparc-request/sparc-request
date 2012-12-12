class Identity::ObisEntitySerializer < Entity::ObisEntitySerializer
  def as_json(entity, options = nil)
    h = super(entity, options)

    identifiers = {
      'ldap_uid'          => entity.ldap_uid,
      'email'             => entity.email,
    }

    identifiers.delete_if { |k, v| v.nil? }

    h['identifiers'].update(identifiers)

    optional_attributes = {
      'uid'               => entity.ldap_uid,
      'last_name'         => entity.last_name,
      'first_name'        => entity.first_name,
      'email'             => entity.email,
      'institution'       => entity.institution,
      'era_commons_name'  => entity.era_commons_name,
      'college'           => entity.college,
      'credentials'       => entity.credentials,
      'department'        => entity.department,
      'subspecialty'      => entity.subspecialty,
      'phone'             => entity.phone,
      'catalog_overlord'  => entity.catalog_overlord,
    }

    optional_attributes.delete_if { |k, v| v.nil? }

    h['attributes'].update(optional_attributes)
    
    return h
  end

  def update_attributes_from_json(entity, h, options = nil)
    super(entity, h, options)

    identifiers = h['identifiers']
    attributes = h['attributes']

    entity.update_attributes!(
        :ldap_uid          => "#{attributes['uid']}@musc.edu",
        :email             => attributes['email'],
        :last_name         => attributes['last_name'],
        :first_name        => attributes['first_name'],
        :institution       => attributes['institution'],
        :college           => attributes['college'],
        :department        => attributes['department'],
        :era_commons_name  => attributes['era_commons_name'],
        :credentials       => attributes['credentials'],
        :subspecialty      => attributes['subspecialty'],
        :phone             => attributes['phone'],
        :catalog_overlord  => attributes['catalog_overlord'])

    update_timestamps_from_json(entity, h)
  end
end

class Identity
  include JsonSerializable
  json_serializer :obisentity, ObisEntitySerializer
  json_serializer :relationships, RelationshipsSerializer
  json_serializer :obissimple, ObisSimpleSerializer
  json_serializer :simplerelationships, ObisSimpleRelationshipsSerializer
end

