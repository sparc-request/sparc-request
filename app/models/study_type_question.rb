class StudyTypeQuestion < ActiveRecord::Base
  default_scope { order('`order`') }
  has_many :study_type_answers

  attr_accessible :order, :question, :friendly_id
end
