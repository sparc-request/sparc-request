class SetAllOneTimeFeeQuantityMinimumsBackToOne < ActiveRecord::Migration
  def change
    PricingMap.all.each do |pm|
      if pm.is_one_time_fee
        pm.update_attributes(:quantity_minimum => 1)
      end
    end
  end
end
