# Copyright © 2011-2016 MUSC Foundation for Research Development.
# All rights reserved.
class RemovePositionInCwfFromOrganizations < ActiveRecord::Migration
  def up
    remove_column :organizations, :position_in_cwf
  end

  def down
    add_column :organizations, :position_in_cwf, :integer
  end
end
