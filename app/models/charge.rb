class Charge < ActiveRecord::Base
  audited

  belongs_to :service_request
  belongs_to :service

  attr_accessible :service_request_id
  attr_accessible :service_id
  attr_accessible :charge_amount
end
