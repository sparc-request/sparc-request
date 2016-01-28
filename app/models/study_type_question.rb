class StudyTypeQuestion < ActiveRecord::Base
  default_scope { order('`order`') }
  belongs_to :study_type_question_group
  has_many :study_type_answers

  attr_accessible :order, :question, :friendly_id, :study_type_question_group_id

  scope :active, -> { joins(:study_type_question_group).where(study_type_question_groups: { active: true })  }
  scope :inactive, -> { joins(:study_type_question_group).where(study_type_question_groups: { active: false }) }
end
