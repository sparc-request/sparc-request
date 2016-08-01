# Copyright © 2011-2016 MUSC Foundation for Research Development.
# All rights reserved.
class ChangeMaxPercentageDefault < ActiveRecord::Migration
  def change
    change_column :subsidy_maps, :max_percentage, :decimal, :default => 0.00, :precision => 5, :scale => 2
  end
end
