# Copyright © 2011-2016 MUSC Foundation for Research Development.
# All rights reserved.
class AddIndexToServiceOneTimeFee < ActiveRecord::Migration
  def change
    add_index "services", ["one_time_fee"], :name => "index_services_on_one_time_fee"
  end
end
