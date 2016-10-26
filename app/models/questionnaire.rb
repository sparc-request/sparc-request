class Questionnaire < ActiveRecord::Base
  belongs_to :service
  has_many :items, dependent: :destroy
  has_many :submissions, dependent: :destroy
  validates :name, presence: true
  scope :active, -> { where(active: true) }

  accepts_nested_attributes_for :items, allow_destroy: true
end
