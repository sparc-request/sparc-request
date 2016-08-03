# Copyright © 2011-2016 MUSC Foundation for Research Development.
# All rights reserved.
class AddOneTimeFeeToServices < ActiveRecord::Migration
  def change
    add_column :services, :one_time_fee, :boolean, :default => false
  end
end
