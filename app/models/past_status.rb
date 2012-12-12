class PastStatus < ActiveRecord::Base
  #Version.primary_key = 'id'
  #has_paper_trail

  belongs_to :sub_service_request

  attr_accessible :sub_service_request_id
  attr_accessible :status
  attr_accessible :date

  default_scope :order => 'date ASC'
end
