class CreateStudyTypeQuestions < ActiveRecord::Migration
  def change
    create_table :study_type_questions do |t|
      t.integer :order
      t.string :question
      t.string :friendly_id

      t.timestamps
    end
  end
end
