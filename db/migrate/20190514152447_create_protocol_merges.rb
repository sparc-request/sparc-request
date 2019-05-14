class CreateProtocolMerges < ActiveRecord::Migration[5.2]
  def change
    create_table :protocol_merges do |t|
      t.integer :master_protocol_id
      t.integer :merged_protocol_id

      t.timestamps
    end
  end
end
