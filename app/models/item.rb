class Item < ActiveRecord::Base
  belongs_to :questionnaire
  has_many :questionnaire_responses, dependent: :destroy
  has_many :item_options, dependent: :destroy
  validates :content, :item_type, presence: true

  accepts_nested_attributes_for :item_options, allow_destroy: true
end
