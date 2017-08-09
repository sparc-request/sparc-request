class Submission < ApplicationRecord
  belongs_to :sub_service_request
  belongs_to :protocol
  belongs_to :identity
  belongs_to :questionnaire
  has_many :questionnaire_responses, dependent: :destroy
  accepts_nested_attributes_for :questionnaire_responses
end
