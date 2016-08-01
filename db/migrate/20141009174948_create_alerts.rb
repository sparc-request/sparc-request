# Copyright © 2011-2016 MUSC Foundation for Research Development.
# All rights reserved.
class CreateAlerts < ActiveRecord::Migration
  def change
    create_table :alerts do |t|
      t.string :alert_type
      t.string :status

      t.timestamps
    end
  end
end
