class StudyTypeQuestionGroup < ActiveRecord::Base
  attr_accessible :active, :group_id
  has_many :study_type_questions
  scope :active, -> {}
  scope :inactive, -> { joins(:study_type_question_group).where(study_type_question_groups: { active: false }) }
end
