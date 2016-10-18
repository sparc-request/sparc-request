class Submission < ActiveRecord::Base
  belongs_to :service
  belongs_to :identity
  belongs_to :questionnaire
  has_many :questionnaire_responses, dependent: :destroy
  accepts_nested_attributes_for :questionnaire_responses
end
