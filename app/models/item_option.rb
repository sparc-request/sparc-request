class ItemOption < ActiveRecord::Base
  belongs_to :item

  validates :content, presence: true, if: :validate_content?
end
