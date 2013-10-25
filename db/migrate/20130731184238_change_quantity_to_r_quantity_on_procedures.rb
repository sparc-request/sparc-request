class ChangeQuantityToRQuantityOnProcedures < ActiveRecord::Migration
  def up
    rename_column :procedures, :quantity, :r_quantity
  end

  def down
  end
end
