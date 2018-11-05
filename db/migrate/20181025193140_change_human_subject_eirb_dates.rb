class ChangeHumanSubjectEirbDates < ActiveRecord::Migration[5.2]
  def change
    change_column :human_subjects_info, :initial_irb_approval_date, :date
    change_column :human_subjects_info, :irb_approval_date, :date
    change_column :human_subjects_info, :irb_expiration_date, :date
  end
end
