class SetUnitsPerQuantityMaxDefault < ActiveRecord::Migration
  def change
    change_column :pricing_maps, :units_per_qty_max, :integer, default: 10000
  end
end
