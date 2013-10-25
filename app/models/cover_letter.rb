class CoverLetter < ActiveRecord::Base
  audited
  belongs_to :sub_service_request
  
  attr_accessible :content, :sub_service_request_id

  validates :content, presence: true
end
