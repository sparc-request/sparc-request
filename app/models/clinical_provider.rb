class ClinicalProvider < ActiveRecord::Base
  audited

  belongs_to :organization
  belongs_to :identity

  attr_accessible :identity_id 
  attr_accessible :organization_id

  def core
    org = Organization.find(self.organization_id)

    org
  end
end

