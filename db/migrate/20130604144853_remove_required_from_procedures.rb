class RemoveRequiredFromProcedures < ActiveRecord::Migration
  def change
    remove_column :procedures, :required
  end
end
