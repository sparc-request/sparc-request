class ChangeDefaultPercentageMagnitude < ActiveRecord::Migration[5.2]
  def change
    SubsidyMap.all.each do |map|
      if map.default_percentage > 0.0
        map.update_attribute(:default_percentage, map.default_percentage * 100.0)
      end
    end
  end
end
