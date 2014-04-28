class Fulfillment < ActiveRecord::Base
  audited

  belongs_to :line_item

  attr_accessible :line_item_id
  attr_accessible :timeframe
  attr_accessible :notes
  attr_accessible :time
  attr_accessible :date
  attr_accessible :quantity
  attr_accessible :unit_quantity
  attr_accessible :quantity_type
  attr_accessible :unit_type

  default_scope :order => 'fulfillments.id ASC'

  QUANTITY_TYPES = ['Min', 'Hours', 'Days', 'Each']
  UNIT_TYPES = ['Slide', 'Sample']
end
