# Copyright © 2011-2016 MUSC Foundation for Research Development.
# All rights reserved.
class AddLineItemsCountToServices < ActiveRecord::Migration
  def change
    add_column :services, :line_items_count, :integer, default: 0
  end
end
