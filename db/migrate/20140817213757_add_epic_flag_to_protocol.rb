# Copyright © 2011-2016 MUSC Foundation for Research Development.
# All rights reserved.
class AddEpicFlagToProtocol < ActiveRecord::Migration
  def change
    add_column :protocols, :selected_for_epic, :boolean, :default => false
  end
end
