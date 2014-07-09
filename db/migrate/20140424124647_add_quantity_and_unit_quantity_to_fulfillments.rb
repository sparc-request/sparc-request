class AddQuantityAndUnitQuantityToFulfillments < ActiveRecord::Migration
  def change
    add_column :fulfillments, :quantity, :integer
    add_column :fulfillments, :unit_quantity, :integer
  end
end
