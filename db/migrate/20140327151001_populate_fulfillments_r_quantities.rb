class PopulateFulfillmentsRQuantities < ActiveRecord::Migration

  class Fulfillment < ActiveRecord::Base
    belongs_to :line_item
    attr_accessible :requested_r_quantity
  end

  def up
    fulfillments = Fulfillment.find(:all)
    fulfillments.each do |fulfillment|
      if fulfillment.line_item
        fulfillment.update_attributes(requested_r_quantity: fulfillment.line_item.quantity)
      end
    end
  end

  def down
    fulfillments = Fulfillment.find(:all)
    fulfillments.each do |fulfillment|
      fulfillment.update_attributes(requested_r_quantity: nil)
    end
  end
end
