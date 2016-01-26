class CreateNewStudyTypeQuestionGroup < ActiveRecord::Migration
  def up
  	study_type_question_group = StudyTypeQuestionGroup.create(active: true)
  end
end
