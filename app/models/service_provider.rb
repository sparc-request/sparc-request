class ServiceProvider < ActiveRecord::Base
  #Version.primary_key = 'id'
  #has_paper_trail

  belongs_to :organization
  belongs_to :identity
  belongs_to :service

  attr_accessible :identity_id
  attr_accessible :organization_id
  attr_accessible :service_id
  attr_accessible :is_primary_contact
  attr_accessible :hold_emails
end

