class AdditionalDetailRenameApprovedToEnabled < ActiveRecord::Migration
  def up
    rename_column :additional_details, :approved, :enabled
  end

  def down
    rename_column :additional_details, :enabled, :approved
  end
end
