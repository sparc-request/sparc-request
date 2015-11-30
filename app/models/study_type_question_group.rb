class StudyTypeQuestionGroup < ActiveRecord::Base
  attr_accessible :active, :group_id
  has_many :study_type_questions
end
