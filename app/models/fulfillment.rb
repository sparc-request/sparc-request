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
  attr_accessible :formatted_date

  default_scope :order => 'fulfillments.id ASC'

  QUANTITY_TYPES = ['Min', 'Hours', 'Days', 'Each']
  CWF_QUANTITY_TYPES = ['Each', 'Sample', 'Aliquot', '3kg unit']
  UNIT_TYPES = ['N/A', 'Each', 'Sample', 'Aliquot', '3kg unit']

  def formatted_date
    format_date self.date
  end

  def formatted_date=(d)
    self.date = parse_date(d)
  end

  private

  def format_date(d)
    d.try(:strftime, '%-m/%d/%Y')
  end

  def parse_date(str)
    begin
      Date.strptime(str.to_s.strip, '%m/%d/%Y')  
    rescue ArgumentError => e
      nil
    end
  end
end
