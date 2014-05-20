class AdminRate < ActiveRecord::Base
  audited

  belongs_to :line_item

  attr_accessible :admin_cost 
end
