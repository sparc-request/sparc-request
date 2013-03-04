class AddUnitsPerQtyMaxToPricingMaps < ActiveRecord::Migration
  def change
  	add_column :pricing_maps, :units_per_qty_max, :integer, :default => 1
  end
end
