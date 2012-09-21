class CreateHumanSubjects < ActiveRecord::Migration
  def change
    create_table :human_subjects do |t|
      t.integer :protocol_id
      t.string :hr_number
      t.string :pro_number
      t.string :irb_of_record
      t.string :submission_type
      t.datetime :irb_approval_date
      t.datetime :irb_expiration_date

      t.timestamps
    end

    add_index :human_subjects, :protocol_id
  end
end
