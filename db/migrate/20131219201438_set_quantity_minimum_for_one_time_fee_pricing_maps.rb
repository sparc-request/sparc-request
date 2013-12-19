class SetQuantityMinimumForOneTimeFeePricingMaps < ActiveRecord::Migration
  def change
    PricingMap.all.each do |pm|
      if pm.is_one_time_fee
        pm.update_attributes(:quantity_minimum => pm.unit_minimum)
      end
    end
  end
end
