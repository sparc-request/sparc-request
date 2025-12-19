class AddIsAdministrativeToServices < ActiveRecord::Migration[7.0]
  def change
    add_column :services, :is_administrative, :boolean
  end
end
