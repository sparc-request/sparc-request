class AddDefaultToLineItemQuantity < ActiveRecord::Migration
  def change
    change_column :line_items, :quantity, :integer, :default => 0
    change_column :line_items, :subject_count, :integer, :default => 1
  end
end
