class AddQuantityTypeToPricingMaps < ActiveRecord::Migration
  def change
    add_column :pricing_maps, :quantity_type, :string
  end
end
