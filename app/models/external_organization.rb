class ExternalOrganization < ApplicationRecord

  belongs_to :protocol

  validates_presence_of :collaborating_org_name, :collaborating_org_type

end
