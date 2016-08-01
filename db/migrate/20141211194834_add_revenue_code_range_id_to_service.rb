# Copyright © 2011-2016 MUSC Foundation for Research Development.
# All rights reserved.
class AddRevenueCodeRangeIdToService < ActiveRecord::Migration
  def change
    add_column :services, :revenue_code_range_id, :integer
  end
end
