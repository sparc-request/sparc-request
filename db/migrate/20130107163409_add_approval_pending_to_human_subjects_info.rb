class AddApprovalPendingToHumanSubjectsInfo < ActiveRecord::Migration
  def change
    add_column :human_subjects_info, :approval_pending, :boolean
  end
end
