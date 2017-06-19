class DropOldCwfTables < ActiveRecord::Migration[4.2][5.0]
  def change
    drop_table :appointments
    drop_table :calendars
    drop_table :procedures
    drop_table :subjects
  end
end
