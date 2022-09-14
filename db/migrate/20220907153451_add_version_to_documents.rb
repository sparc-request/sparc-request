class AddVersionToDocuments < ActiveRecord::Migration[5.2]
  def change
    add_column :documents, :version, :date
  end
end
