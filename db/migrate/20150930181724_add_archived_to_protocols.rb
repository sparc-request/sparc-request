# Copyright © 2011-2016 MUSC Foundation for Research Development.
# All rights reserved.
class AddArchivedToProtocols < ActiveRecord::Migration
  def change
    add_column :protocols, :archived, :boolean, default: false
  end
end
