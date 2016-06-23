class AddPercentSubsidyToSubsidy < ActiveRecord::Migration
  def change
    add_column :subsidies, :percent_subsidy, :float
  end
end


