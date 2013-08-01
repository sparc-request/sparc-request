class AddTQuantityToProcedures < ActiveRecord::Migration
  def change
    add_column :procedures, :t_quantity, :integer
  end
end
