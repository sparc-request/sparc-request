class Item < ActiveRecord::Base
  belongs_to :questionnaire
  has_many :questionnaire_responses, dependent: :destroy
  validates :content, :item_type, :required, presence: true
end
