class Fulfillment < ActiveRecord::Base
  audited

  belongs_to :line_item

  attr_accessible :line_item_id
  attr_accessible :timeframe
  attr_accessible :notes
  attr_accessible :time
  attr_accessible :date

  # TODO: order by date/id instead of just by date?
  default_scope :order => 'fulfillments.id ASC'

  QUANTITY_TYPES = ['Min', 'Hours', 'Days', 'Each']
end
