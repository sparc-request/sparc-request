class AddPositionAndNameToAppointments < ActiveRecord::Migration
  def change
    add_column :appointments, :position, :integer
    add_column :appointments, :name, :string
  end
end
