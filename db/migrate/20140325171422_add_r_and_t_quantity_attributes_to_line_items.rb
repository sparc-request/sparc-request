class AddRAndTQuantityAttributesToLineItems < ActiveRecord::Migration
  def change
    add_column :line_items, :requested_t_quantity, :integer
    add_column :line_items, :fulfilled_r_quantity, :integer
    add_column :line_items, :fulfilled_t_quantity, :integer
  end
end
