class RemoveUnusedTables < ActiveRecord::Migration[5.2]
  class ToastMessage < ApplicationRecord
    audited
  
    belongs_to :sender,     class_name: 'Identity', foreign_key: 'from'
    belongs_to :recipient,  class_name: 'Identity', foreign_key: 'to'
  end

  def up
    drop_table :lookups
    drop_table :toast_messages
    drop_table :versions
  end

  def down
    create_table :lookups do |t|
      t.integer :new_id
      t.string :old_id
    end

    create_table :toast_messages do |t|
      t.integer :from
      t.integer :to
      t.string :sending_class
      t.integer :sending_class_id
      t.string :message

      t.timestamps
    end
    add_index :toast_messages, [:sending_class, :sending_class_id]

    create_table :versions do |t|
      t.string   :item_type, null: false
      t.integer  :item_id,   null: false
      t.string   :event,     null: false
      t.string   :whodunnit
      t.text     :object
      t.datetime :created_at
    end
    add_index :versions, [:item_type, :item_id]
  end
end
