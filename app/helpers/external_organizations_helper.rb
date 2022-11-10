module ExternalOrganizationsHelper
   def get_name external_organization
    name_category = PermissibleValue.get_hash :collaborating_org_name
    name = external_organization.collaborating_org_name_other? ? external_organization.collaborating_org_name_other : name_category[external_organization.collaborating_org_name]
   end

  def get_type external_organization
    type_category = PermissibleValue.get_hash :collaborating_org_type
    type = external_organization.collaborating_org_type_other? ? external_organization.collaborating_org_type_other : type_category[external_organization.collaborating_org_type]
  end
end
