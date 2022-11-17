class AddNameOtherAndTypeOtherToExternalOrganizations < ActiveRecord::Migration[5.2]
  def change
    add_column :external_organizations, :collaborating_org_name_other, :string
    add_column :external_organizations, :collaborating_org_type_other, :string
  end
end
