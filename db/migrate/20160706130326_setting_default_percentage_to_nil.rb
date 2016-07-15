class SettingDefaultPercentageToNil < ActiveRecord::Migration
  def change
  	change_column :subsidies, :percent_subsidy, :float, :default => nil

    Subsidy.all.each do |sub|
      sub.update_attribute :percent_subsidy, nil unless :percent_subsidy
    end
  end
end
