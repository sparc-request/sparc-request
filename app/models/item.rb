class Item < ActiveRecord::Base
  belongs_to :questionnaire
  validates :content, :type, :required, presence: true
end
