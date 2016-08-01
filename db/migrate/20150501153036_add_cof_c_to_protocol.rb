# Copyright © 2011-2016 MUSC Foundation for Research Development.
# All rights reserved.
class AddCofCToProtocol < ActiveRecord::Migration
  def change
    add_column :protocols, :has_cofc, :boolean
  end
end
