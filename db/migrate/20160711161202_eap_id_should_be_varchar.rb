# Copyright © 2011-2016 MUSC Foundation for Research Development.
# All rights reserved.
class EapIdShouldBeVarchar < ActiveRecord::Migration
  def change
    change_column :services, :eap_id, :string
  end
end
