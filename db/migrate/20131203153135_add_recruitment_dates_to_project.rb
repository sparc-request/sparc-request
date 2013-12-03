class AddRecruitmentDatesToProject < ActiveRecord::Migration
  def change
    add_column :protocols, :recruitment_start_date, :datetime
    add_column :protocols, :recruitment_end_date, :datetime
  end
end
