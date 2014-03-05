class Tag < ActiveRecord::Base
  audited

  attr_accessible :name
end

