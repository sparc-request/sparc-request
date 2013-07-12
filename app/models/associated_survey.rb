class AssociatedSurvey < ActiveRecord::Base
  belongs_to :surveyable, :polymorphic => true
  belongs_to :survey
  
  validates :survey_id, :presence => true, :uniqueness => {:scope => [:surveyable_id, :surveyable_type]}
  validates :surveyable_id, :presence => true
  validates :surveyable_type, :presence => true
  attr_accessible :survey_id, :surveyable_id, :surveyable_type
end
