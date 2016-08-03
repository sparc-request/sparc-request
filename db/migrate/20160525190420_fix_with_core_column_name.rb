# Copyright © 2011-2016 MUSC Foundation for Research Development.
# All rights reserved.
class FixWithCoreColumnName < ActiveRecord::Migration
  def change
    rename_column :protocol_filters, :with_core, :with_organization
  end
end
