class ServiceRelation < ActiveRecord::Base
  #Version.primary_key = 'id'
  #has_paper_trail

  belongs_to :service
  belongs_to :related_service, :class_name => "Service", :foreign_key => "related_service_id"

  attr_accessible :service_id
  attr_accessible :related_service_id
  attr_accessible :optional
end

