class CreateOncoreRecords < ActiveRecord::Migration[5.2]
  def change
    create_table :oncore_records do |t|
      t.references :protocol
      t.integer    :calendar_version
      t.string     :status
      t.timestamps
    end
  end
end
