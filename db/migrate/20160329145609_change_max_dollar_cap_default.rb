# Copyright © 2011-2016 MUSC Foundation for Research Development.
# All rights reserved.
class ChangeMaxDollarCapDefault < ActiveRecord::Migration
  def change
    change_column :subsidy_maps, :max_dollar_cap, :decimal, :default => 0.0000, :precision => 12, :scale => 4
  end
end
