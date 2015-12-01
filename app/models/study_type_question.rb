class StudyTypeQuestion < ActiveRecord::Base
  default_scope { order('`order`') }
  belongs_to :study_type_question_group
  has_many :study_type_answers

  attr_accessible :order, :question, :friendly_id, :study_type_question_group_id
  scope :active, -> {where(study_type_question_group_id: StudyTypeQuestionGroup.active.pluck(:id).first)}
  scope :inactive, -> {where(study_type_question_group_id: StudyTypeQuestionGroup.active.pluck(:id).first)}
end
