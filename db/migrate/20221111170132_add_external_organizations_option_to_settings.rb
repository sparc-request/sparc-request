class AddExternalOrganizationsOptionToSettings < ActiveRecord::Migration[5.2]
  def change
    Setting.create(key: "use_external_organizations", value: 'true', data_type: 'boolean', friendly_name: "Use External Organizations", description: "This determines whether the application will display External Organizations section on a Study Form.")
  end
end
