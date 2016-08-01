# Copyright © 2011-2016 MUSC Foundation for Research Development.
# All rights reserved.
class RemoveIsOneTimeFeeFromPricingMaps < ActiveRecord::Migration
  def up
    remove_column :pricing_maps, :is_one_time_fee
  end

  def down
    add_column :pricing_maps, :is_one_time_fee
  end
end
