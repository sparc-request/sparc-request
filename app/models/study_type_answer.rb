class StudyTypeAnswer < ActiveRecord::Base
	
  attr_accessible :answer, :protocol_id, :study_type_question_id
end
