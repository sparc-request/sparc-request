class CreateCoverLetters < ActiveRecord::Migration
  def change
    create_table :cover_letters do |t|
      t.text :content
      t.references :sub_service_request

      t.timestamps
    end

    add_index :cover_letters, :sub_service_request_id
  end
end
