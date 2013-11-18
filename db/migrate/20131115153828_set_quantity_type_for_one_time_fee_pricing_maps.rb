class SetQuantityTypeForOneTimeFeePricingMaps < ActiveRecord::Migration
  def change
    PricingMap.all.each do |pm|
      if pm.is_one_time_fee
        pm.update_attributes(:quantity_type => pm.unit_type)
      end
    end
  end
end
