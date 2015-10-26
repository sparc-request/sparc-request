class ChangeSrcApprovedToCommitteeApproved < ActiveRecord::Migration
  def up
    rename_column :sub_service_requests, :src_approved, :committee_approved
  end

  def down
    rename_column :sub_service_requests, :committee_approved, :src_approved
  end
end
