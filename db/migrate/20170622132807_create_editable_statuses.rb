class CreateEditableStatuses < ActiveRecord::Migration[5.0]
  def up
    create_table :editable_statuses do |t|
      t.references  :organization,  index: true, foreign_key: true
      t.string      :status,        null: false

      t.timestamps                  null: false
    end
  end

  def down
    drop_table :editable_statuses
  end
end
