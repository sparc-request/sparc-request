class SetNullMaxDollarCapsTo0 < ActiveRecord::Migration
  def change
    null_max_dollar_caps = SubsidyMap.where(max_dollar_cap: nil)
    null_max_dollar_caps.each do |null_max_dollar_cap|
      null_max_dollar_cap.update_attribute(:max_dollar_cap, 0.0000)
    end
  end
end
