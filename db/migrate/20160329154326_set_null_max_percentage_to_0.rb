class SetNullMaxPercentageTo0 < ActiveRecord::Migration
  def change
    null_max_percentages = SubsidyMap.where(max_percentage: nil)
    null_max_percentages.each do |null_max_percentage|
      null_max_percentage.update_attribute(:max_percentage, 0.00)
    end
  end
end
