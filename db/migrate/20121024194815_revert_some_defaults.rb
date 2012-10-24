class RevertSomeDefaults < ActiveRecord::Migration
  def up
    change_column :line_items, :quantity, :integer, :default => nil
    change_column :line_items, :subject_count, :integer, :default => nil
    change_column :line_items, :units_per_quantity, :integer, :default => 0
  end

  def down
  end
end
