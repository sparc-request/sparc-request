# Copyright © 2011-2016 MUSC Foundation for Research Development.
# All rights reserved.
class WithCoreShouldBeASavedObject < ActiveRecord::Migration
  def up
    change_column :protocol_filters, :with_core, :string
  end

  def down
  	change_column :protocol_filters, :with_core, :tinyint
  end
end
