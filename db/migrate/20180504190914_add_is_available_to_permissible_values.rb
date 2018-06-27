class AddIsAvailableToPermissibleValues < ActiveRecord::Migration[5.1]
  def up
    add_column :permissible_values, :is_available, :boolean

    PermissibleValue.update_all(is_available: true)
  end

  def down
    remove_column :permissible_values, :is_available
  end
end
