class Approval < ActiveRecord::Base
  #Version.primary_key = 'id'
  #has_paper_trail

  belongs_to :service_request
  belongs_to :sub_service_request
  belongs_to :identity

  attr_accessible :service_request_id
  attr_accessible :sub_service_request_id
  attr_accessible :identity_id
  attr_accessible :approval_date
  attr_accessible :approval_type
end
