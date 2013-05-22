class Procedure < ActiveRecord::Base
  audited

  belongs_to :appointment
  belongs_to :visit
  belongs_to :service
  belongs_to :line_item
  attr_accessible :visit_id
  attr_accessible :service_id
  attr_accessible :line_item_id
end
