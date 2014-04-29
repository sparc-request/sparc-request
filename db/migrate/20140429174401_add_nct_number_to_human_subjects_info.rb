class AddNctNumberToHumanSubjectsInfo < ActiveRecord::Migration
  def change
    add_column :human_subjects_info, :nct_number, :string
  end
end
