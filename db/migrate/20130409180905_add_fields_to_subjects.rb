class AddFieldsToSubjects < ActiveRecord::Migration
  def change
    add_column :subjects, :arm_id, :integer
    
    add_column :subjects, :name, :string
    add_column :subjects, :mrn, :string
    add_column :subjects, :external_subject_id, :string
    add_column :subjects, :dob, :date
    add_column :subjects, :gender, :string
    add_column :subjects, :ethnicity, :string
    
  end
end
