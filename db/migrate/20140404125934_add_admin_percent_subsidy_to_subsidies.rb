class AddAdminPercentSubsidyToSubsidies < ActiveRecord::Migration
  def change
    add_column :subsidies, :admin_percent_subsidy, :float, default: 0.0
  end
end
