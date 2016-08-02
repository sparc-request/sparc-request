class Item < ActiveRecord::Base
  belongs_to :questionnaire
  has_many :questionnaire_responses
  validates :content, :item_type, :required, presence: true
end
