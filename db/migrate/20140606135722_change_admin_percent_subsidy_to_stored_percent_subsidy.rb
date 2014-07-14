class ChangeAdminPercentSubsidyToStoredPercentSubsidy < ActiveRecord::Migration
  def up
    rename_column :subsidies, :admin_percent_subsidy, :stored_percent_subsidy
  end

  def down
  end
end
