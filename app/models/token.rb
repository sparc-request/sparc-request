class Token < ActiveRecord::Base
  #Version.primary_key = 'id'
  #has_paper_trail

  belongs_to :service_request
  belongs_to :identity

  attr_accessible :service_request_id
  attr_accessible :identity_id
  attr_accessible :token
end
