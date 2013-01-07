class CreateNotes < ActiveRecord::Migration
  def change
    create_table :notes do |t|
      t.integer :identity_id
      t.integer :sub_service_request_id
      t.string :body

      t.timestamps
    end
  end
end
