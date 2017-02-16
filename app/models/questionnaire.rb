class Questionnaire < ActiveRecord::Base
  belongs_to :service
  has_many :items, dependent: :destroy
  has_many :submissions, dependent: :destroy
  validates :name, presence: true
  scope :active, -> { where(active: true) }

  accepts_nested_attributes_for :items, allow_destroy: true

  validate :at_least_one_item

  def at_least_one_item
    if self.items.select(&:valid?).empty?
      errors.add(
        :_, 'At least one question must exist in order to create a form.'
      )
    end
  end
end

