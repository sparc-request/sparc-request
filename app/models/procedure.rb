class Procedure < ActiveRecord::Base
  belongs_to :appointment
  belongs_to :visit
  belongs_to :service
  belongs_to :line_item
  attr_accessible :appointment_id
  attr_accessible :visit_id
  attr_accessible :service_id
  attr_accessible :line_item_id
  attr_accessible :completed

  def required?
    self.visit.to_be_performed?
  end
end
