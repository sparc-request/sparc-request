# Copyright © 2011-2016 MUSC Foundation for Research Development.
# All rights reserved.
class AddStudyTypeQuestionGroupIdColumnToStudyTypeQuestions < ActiveRecord::Migration
  def up
  	add_column :study_type_questions, :study_type_question_group_id, :integer
        StudyTypeQuestion.reset_column_information
  end

  def down
  	remove_column :study_type_questions, :study_type_question_group_id
  end
end
