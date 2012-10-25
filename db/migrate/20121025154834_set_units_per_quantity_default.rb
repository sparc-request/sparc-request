class SetUnitsPerQuantityDefault < ActiveRecord::Migration
  def up
    change_column :line_items, :units_per_quantity, :integer, :default => 1
  end

  def down
  end
end
