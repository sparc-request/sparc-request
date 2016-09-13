class Submission < ActiveRecord::Base
  belongs_to :service
  belongs_to :identity
  has_many :questionnaire_responses
  accepts_nested_attributes_for :questionnaire_responses
end
