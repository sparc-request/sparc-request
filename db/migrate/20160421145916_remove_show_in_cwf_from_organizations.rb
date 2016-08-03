# Copyright © 2011-2016 MUSC Foundation for Research Development.
# All rights reserved.
class RemoveShowInCwfFromOrganizations < ActiveRecord::Migration
  def change
    remove_column :organizations, :show_in_cwf, :boolean
  end
end
