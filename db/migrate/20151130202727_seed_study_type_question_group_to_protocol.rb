# Copyright © 2011-2016 MUSC Foundation for Research Development.
# All rights reserved.
class SeedStudyTypeQuestionGroupToProtocol < ActiveRecord::Migration
  def up
  	study_type_question_group = StudyTypeQuestionGroup.create
  	Protocol.update_all(study_type_question_group_id: study_type_question_group.id)
  end
end
