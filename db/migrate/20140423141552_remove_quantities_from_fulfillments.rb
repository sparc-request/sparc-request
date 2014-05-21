class RemoveQuantitiesFromFulfillments < ActiveRecord::Migration
  def change
    remove_column :fulfillments, :requested_r_quantity
    remove_column :fulfillments, :requested_t_quantity
    remove_column :fulfillments, :fulfilled_r_quantity
    remove_column :fulfillments, :fulfilled_t_quantity
  end
end
