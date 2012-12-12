class Approval::ObisEntitySerializer
  def as_json(approval, options = nil)
    return [
        approval.identity.obisid,
        approval.approval_date.utc.strftime('%F %T %Z')
    ]
  end

  def update_from_json(approval, h, options = nil)
    identity = Identity.find_by_obisid(h[0])
    approval.update_attributes!(
        identity_id: identity.id,
        approval_date: h[1] ? Time.parse(h[1]) : nil)
  end
end

class Approval
  include JsonSerializable
  json_serializer :obisentity, ObisEntitySerializer
end

