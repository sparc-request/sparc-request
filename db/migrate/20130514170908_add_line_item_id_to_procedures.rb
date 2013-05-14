class AddLineItemIdToProcedures < ActiveRecord::Migration
  def change
  	add_column :procedures, :line_item_id, :integer
  end
end
