class CreateStudyTypeAnswers < ActiveRecord::Migration
  def change
    create_table :study_type_answers do |t|
      t.integer :protocol_id
      t.integer :study_type_question_id
      t.boolean :answer

      t.timestamps
    end
  end
end
