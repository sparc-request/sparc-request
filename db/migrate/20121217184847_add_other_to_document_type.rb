class AddOtherToDocumentType < ActiveRecord::Migration
  def change
    add_column :documents, :doc_type_other, :string
  end
end
