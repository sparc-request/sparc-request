module Shard
  module Fulfillment
    class Fulfillment < Shard::Fulfillment::Base
      self.table_name = 'fulfillments'

      belongs_to :line_item
    end
  end
end