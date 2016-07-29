class Item < ActiveRecord::Base
  belongs_to :questionnaire
  validates :content, :item_type, :required, presence: true
end
