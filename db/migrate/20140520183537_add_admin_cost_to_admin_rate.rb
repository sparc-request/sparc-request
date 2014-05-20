class AddAdminCostToAdminRate < ActiveRecord::Migration
  def change
    add_column :admin_rates, :admin_cost, :integer
  end
end
