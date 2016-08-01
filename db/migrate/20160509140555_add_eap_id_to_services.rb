# Copyright © 2011-2016 MUSC Foundation for Research Development.
# All rights reserved.
class AddEapIdToServices < ActiveRecord::Migration
  def change
    add_column :services, :eap_id, :string
  end
end
