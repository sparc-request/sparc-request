class Payment < ActiveRecord::Base
  attr_accessible :sub_service_request_id
  attr_accessible :date_submitted
  attr_accessible :amount_invoiced
  attr_accessible :amount_received
  attr_accessible :date_received
  attr_accessible :payment_method
  attr_accessible :details

  validates :amount_invoiced, numericality: true
  validates :amount_received, numericality: true

  belongs_to :sub_service_request
end
