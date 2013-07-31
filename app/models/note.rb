class Note < ActiveRecord::Base
  audited

  belongs_to :identity
  belongs_to :sub_service_request
  belongs_to :appointment

  attr_accessible :body, :identity_id, :sub_service_request_id

  validates_presence_of :body
end
