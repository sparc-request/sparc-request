class AddRAndTQuantitiesToFulfillments < ActiveRecord::Migration
  def change
    add_column :fulfillments, :requested_r_quantity, :integer
    add_column :fulfillments, :requested_t_quantity, :integer
    add_column :fulfillments, :fulfilled_r_quantity, :integer
    add_column :fulfillments, :fulfilled_t_quantity, :integer
  end
end
