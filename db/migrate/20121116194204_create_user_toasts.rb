class CreateUserToasts < ActiveRecord::Migration
  def change
    create_table :toast_messages do |t|
      t.integer :from
      t.integer :to
      t.string :sending_class
      t.integer :sending_class_id
      t.string :message

      t.timestamps
    end
  end
end
