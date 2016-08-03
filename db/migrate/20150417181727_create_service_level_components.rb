# Copyright © 2011-2016 MUSC Foundation for Research Development.
# All rights reserved.
class CreateServiceLevelComponents < ActiveRecord::Migration
  def change
    create_table :service_level_components do |t|
      t.references :service
      t.string :component
      t.integer :position, default: 0

      t.timestamps
    end
    add_index :service_level_components, :service_id
  end
end
