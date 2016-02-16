class ChangeIsAvailableDefaultToTrue < ActiveRecord::Migration
  def change
    change_column :organizations, :is_available, :boolean, default: true
    change_column :services, :is_available, :boolean, default: true
  end
end
