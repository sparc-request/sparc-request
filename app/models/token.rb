class Token < ActiveRecord::Base
  #Version.primary_key = 'id'
  #has_paper_trail

  belongs_to :service_request
  belongs_to :identity

  attr_accessible :service_request_id
  attr_accessible :identity_id
  attr_accessible :token
end

class Token::ObisEntitySerializer
  def as_json(token, options = nil)
    return [
      token.token,
      token.identity.obisid,
    ]
  end

  def update_from_json(token, h, options = nil)
    identity = Identity.find_by_obisid(h[1])
    token.update_attributes!(
        token: h[0],
        identity_id: identity.id)
  end
end

class Token
  include JsonSerializable
  json_serializer :obisentity, ObisEntitySerializer
end

