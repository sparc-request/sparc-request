class AddHiddenToLineItemsVisits < ActiveRecord::Migration
  def change
    add_column :line_items_visits, :hidden, :boolean
  end
end
