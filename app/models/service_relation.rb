class ServiceRelation < ActiveRecord::Base
  audited

  belongs_to :service
  belongs_to :related_service, :class_name => "Service", :foreign_key => "related_service_id"

  attr_accessible :service_id
  attr_accessible :related_service_id
  attr_accessible :optional
  attr_accessible :linked_quantity
  attr_accessible :linked_quantity_total
end

