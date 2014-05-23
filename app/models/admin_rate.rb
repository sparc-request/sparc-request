class AdminRate < ActiveRecord::Base
  audited

  belongs_to :line_item

  attr_accessible :admin_cost 
  attr_accessible :line_item_id
end
