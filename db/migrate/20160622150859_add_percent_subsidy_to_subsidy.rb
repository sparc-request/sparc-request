# Copyright © 2011-2016 MUSC Foundation for Research Development.
# All rights reserved.
class AddPercentSubsidyToSubsidy < ActiveRecord::Migration
  def change
    add_column :subsidies, :percent_subsidy, :float, default: 0
  end
end


