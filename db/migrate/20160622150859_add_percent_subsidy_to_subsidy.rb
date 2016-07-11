class AddPercentSubsidyToSubsidy < ActiveRecord::Migration
  def change
    add_column :subsidies, :percent_subsidy, :float, default: 0
  end
end


