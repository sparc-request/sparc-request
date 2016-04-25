class DropClickCountersTable < ActiveRecord::Migration
  def change
    drop_table :click_counters
  end
end
