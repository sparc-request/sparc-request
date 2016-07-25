class Questionnaire < ActiveRecord::Base
  belongs_to :service
  has_many :items

  accepts_nested_attributes_for :items
end
