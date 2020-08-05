class AddShareAllToDocuments < ActiveRecord::Migration[5.2]
  def change
    add_column :documents, :share_all, :boolean
  end
end
