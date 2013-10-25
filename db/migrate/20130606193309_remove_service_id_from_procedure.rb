class RemoveServiceIdFromProcedure < ActiveRecord::Migration
  def change
    remove_column :procedures, :service_id
  end
end
