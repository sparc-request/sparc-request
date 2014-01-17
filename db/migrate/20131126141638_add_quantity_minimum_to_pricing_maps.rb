class AddQuantityMinimumToPricingMaps < ActiveRecord::Migration
  def change
    add_column :pricing_maps, :quantity_minimum, :integer, :default => 1
  end
end
