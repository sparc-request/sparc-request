class EpicRight < ActiveRecord::Base
  audited
  belongs_to :project_role

  attr_accessible :project_role_id
  attr_accessible :right
  attr_accessible :new
  attr_accessible :position

  attr_accessor :new
  attr_accessor :position
end
