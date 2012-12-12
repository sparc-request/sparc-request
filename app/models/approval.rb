class Approval < ActiveRecord::Base
  #Version.primary_key = 'id'
  #has_paper_trail

  belongs_to :service_request
  belongs_to :identity

  attr_accessible :service_request_id
  attr_accessible :identity_id
  attr_accessible :approval_date
end

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

