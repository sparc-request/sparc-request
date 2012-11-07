class CreateMessages < ActiveRecord::Migration
  def change
    create_table :messages do |t|
      t.integer  :notification_id
      t.integer  :to
      t.integer  :from
      t.string   :email
      t.string   :subject
      t.text     :body
      t.boolean  :read

      t.timestamps
    end
  end
end
