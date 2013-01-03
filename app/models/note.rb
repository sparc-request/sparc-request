class Note < ActiveRecord::Base
  belongs_to :identity
  belongs_to :sub_service_request
  
  attr_accessible :body, :identity_id, :sub_service_request_id
end
