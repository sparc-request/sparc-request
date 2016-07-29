class Questionnaire < ActiveRecord::Base
  belongs_to :service
  has_many :items, dependent: :destroy
  validates :name, presence: true

  accepts_nested_attributes_for :items
end
