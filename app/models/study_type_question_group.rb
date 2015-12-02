class StudyTypeQuestionGroup < ActiveRecord::Base
  attr_accessible :active, :group_id
  has_many :study_type_questions
  scope :inactive, -> {where(active:false)}
  scope :active, -> {where(active:true)}

  
end
