class CreateClickCounters < ActiveRecord::Migration
  def change
    create_table :click_counters do |t|
      t.integer :click_count

      t.timestamps null: false
    end
  end
end
