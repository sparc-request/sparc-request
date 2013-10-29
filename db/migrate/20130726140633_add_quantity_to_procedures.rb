class AddQuantityToProcedures < ActiveRecord::Migration
  def change
  	add_column :procedures, :quantity, :integer
  end
end
