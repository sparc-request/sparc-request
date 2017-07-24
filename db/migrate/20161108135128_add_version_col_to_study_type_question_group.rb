class AddVersionColToStudyTypeQuestionGroup < ActiveRecord::Migration[4.2]
  def up
    add_column :study_type_question_groups, :version, :integer, after: :id
    StudyTypeQuestionGroup.reset_column_information
    StudyTypeQuestionGroup.find(1).update(version: 1)
    StudyTypeQuestionGroup.find(2).update(version: 2)
    StudyTypeQuestionGroup.find(3).update(version: 3)
    change_column :study_type_questions, :question, :text
  end

  def down
    remove_column :study_type_question_groups, :version
  end
end
