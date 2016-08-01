# Copyright © 2011-2016 MUSC Foundation for Research Development.
# All rights reserved.
class Alert < ActiveRecord::Base
  attr_accessible :alert_type
  attr_accessible :status
end