class PastStatus < ActiveRecord::Base
  #Version.primary_key = 'id'
  #has_paper_trail

  belongs_to :sub_service_request

  attr_accessible :sub_service_request_id
  attr_accessible :status
  attr_accessible :date

  default_scope :order => 'date ASC'
end

class PastStatus::ObisEntitySerializer
  def as_json(past_status, options = nil)
    if past_status.date then
      date = past_status.date.strftime('%Y-%m-%d %H:%M:%S')
    else
      date = nil
    end

    return [
        past_status.status,
        date,
      ]
  end

  def update_from_json(past_status, h, options = nil)
    past_status.update_attributes!(
        status: h[0],
        date:   h[1] ? Time.parse(h[1]) : nil)
  end
end

class PastStatus
  include JsonSerializable
  json_serializer :obisentity, ObisEntitySerializer
end

