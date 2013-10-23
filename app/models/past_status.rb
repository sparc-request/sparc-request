class PastStatus < ActiveRecord::Base
  audited

  belongs_to :sub_service_request

  attr_accessible :sub_service_request_id
  attr_accessible :status
  attr_accessible :date

  attr_accessor :changed_to

  default_scope :order => 'date ASC'
  
### audit reporting methods ###
  
  def audit_excluded_fields
    {'create' => ['sub_service_request_id', 'date']}
  end
  
  def audit_label audit
    "Past status logged for #{sub_service_request.display_id}"
  end

  ### end audit reporting methods ###
end
