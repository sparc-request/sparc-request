class AddHumanSubjectsInitialIrbApprovalDate < ActiveRecord::Migration[5.2]
  def up
    add_column :human_subjects_info, :initial_irb_approval_date, :datetime, after: :submission_type
  end

  def down
    remove_column :human_subjects_info, :initial_irb_approval_date
  end
end
