class ExternalOrganization < ApplicationRecord

  belongs_to :protocol

  validates_presence_of :collaborating_org_name, :collaborating_org_type
  attr_accessor :new
  attr_accessor :position

  NAMES = PermissibleValue.get_hash 'collaborating_org_name'
  TYPES = PermissibleValue.get_hash 'collaborating_org_type'

end
