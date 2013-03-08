class AvailableStatus < ActiveRecord::Base

  belongs_to :organization
  
  attr_accessible :organization_id
  attr_accessible :status
  attr_accessible :new
  attr_accessible :position
  attr_accessor :new
  attr_accessor :position

  TYPES = AVAILABLE_STATUSES
end
