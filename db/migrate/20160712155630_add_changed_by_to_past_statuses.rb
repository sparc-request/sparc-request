# Copyright © 2011-2016 MUSC Foundation for Research Development.
# All rights reserved.
class AddChangedByToPastStatuses < ActiveRecord::Migration
  def change
    add_column :past_statuses, :changed_by_id, :integer
    add_index :past_statuses, :changed_by_id
  end
end
