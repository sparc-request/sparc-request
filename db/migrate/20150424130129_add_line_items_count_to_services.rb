class AddLineItemsCountToServices < ActiveRecord::Migration
  def change
    add_column :services, :line_items_count, :integer, default: 0
  end
end
