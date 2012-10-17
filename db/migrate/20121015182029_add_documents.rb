class AddDocuments < ActiveRecord::Migration
  def up
    create_table :documents do |t|
      t.belongs_to :sub_service_request
      t.datetime :deleted_at
      t.string :doc_type
      t.timestamps
    end
    add_attachment :documents, :document
  end

  def down
    drop_table :documents
  end
end
