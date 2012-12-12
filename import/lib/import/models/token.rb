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

