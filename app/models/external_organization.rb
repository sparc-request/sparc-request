class ExternalOrganization < ApplicationRecord

    # audited

    # attr_accessor :new
    # attr_accessor :position

    belongs_to :protocol
    # TYPES = PermissibleValue.get_hash('external_organization_type')

end
