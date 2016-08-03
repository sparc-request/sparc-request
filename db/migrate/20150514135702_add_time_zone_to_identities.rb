# Copyright © 2011-2016 MUSC Foundation for Research Development.
# All rights reserved.
class AddTimeZoneToIdentities < ActiveRecord::Migration
  def change
    add_column :identities, :time_zone, :string, default: "Eastern Time (US & Canada)"
  end
end
