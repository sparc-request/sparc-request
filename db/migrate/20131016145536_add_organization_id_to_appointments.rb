class AddOrganizationIdToAppointments < ActiveRecord::Migration
  def change
    add_column :appointments, :organization_id, :integer

    add_index :appointments, :organization_id
  end
end
