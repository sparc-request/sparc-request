class SuperUser < ActiveRecord::Base
  audited

  belongs_to :organization
  belongs_to :identity

  attr_accessible :identity_id
  attr_accessible :organization_id
end

