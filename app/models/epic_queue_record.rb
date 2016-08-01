# Copyright © 2011-2016 MUSC Foundation for Research Development.
# All rights reserved.
class EpicQueueRecord < ActiveRecord::Base
  attr_accessible :protocol_id, :status
end
