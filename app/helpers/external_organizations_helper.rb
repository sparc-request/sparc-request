module ExternalOrganizationsHelper
   def get_name external_organization
    name_category = PermissibleValue.get_hash :collaborating_org_name
    name = name_category[external_organization.collaborating_org_name]
   end

  def get_type external_organization
    type_category = PermissibleValue.get_hash :collaborating_org_type
    type = type_category[external_organization.collaborating_org_type]
  end
end
