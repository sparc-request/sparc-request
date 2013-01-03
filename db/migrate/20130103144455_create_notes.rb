class CreateNotes < ActiveRecord::Migration
  def change
    create_table :notes do |t|
      t.int :identity_id
      t.int :sub_service_request_id
      t.string :body

      t.timestamps
    end
  end
end
