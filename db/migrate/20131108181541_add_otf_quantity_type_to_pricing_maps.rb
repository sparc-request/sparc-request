class AddOtfQuantityTypeToPricingMaps < ActiveRecord::Migration
  def change
    add_column :pricing_maps, :otf_unit_type, :string, default: "N/A"
  end
end
