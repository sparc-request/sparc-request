# Copyright © 2011-2016 MUSC Foundation for Research Development.
# All rights reserved.
class CreateNewStudyTypeQuestionGroup < ActiveRecord::Migration
  def up
  	study_type_question_group = StudyTypeQuestionGroup.create(active: true)
  end
end
