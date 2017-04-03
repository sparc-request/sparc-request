class ItemOption < ApplicationRecord
  belongs_to :item

  validates :content, presence: true, if: :validate_content?
end
