class CreateDocumentGroupingAndAddGroupingIdToDocument < ActiveRecord::Migration
  def up
    create_table :document_groupings do |t|
      t.belongs_to :service_request
      t.timestamps
    end

    add_column :documents, :document_grouping_id, :integer
  end
    
  def down
    drop_table :document_groupings
    remove_column :documents, :document_grouping_id
  end
end
