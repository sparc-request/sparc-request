class AddQuantityTypeAndUnitTypeToFulfillments < ActiveRecord::Migration
  def change
    add_column :fulfillments, :unit_type, :string
    add_column :fulfillments, :quantity_type, :string
  end
end
