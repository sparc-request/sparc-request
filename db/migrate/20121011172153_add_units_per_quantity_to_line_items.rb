class AddUnitsPerQuantityToLineItems < ActiveRecord::Migration
  def change
    add_column :line_items, :units_per_quantity, :integer, :default => 1
  end
end
