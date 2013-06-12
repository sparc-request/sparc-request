class RemoveHiddenFromLineItemsVisits < ActiveRecord::Migration
  def change
    remove_column :line_items_visits, :hidden
  end
end
