class AddServiceIdToProcedures < ActiveRecord::Migration
  def change
    add_column :procedures, :service_id, :integer
  end
end
