class PastStatus < ActiveRecord::Base
  audited

  belongs_to :sub_service_request

  attr_accessible :sub_service_request_id
  attr_accessible :status
  attr_accessible :date

  attr_accessor :changed_to

  default_scope :order => 'date ASC'
end
