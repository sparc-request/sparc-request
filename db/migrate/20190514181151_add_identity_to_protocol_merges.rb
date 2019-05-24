class AddIdentityToProtocolMerges < ActiveRecord::Migration[5.2]
  def up
    add_column :protocol_merges, :identity_id, :integer, after: :merged_protocol_id
  end

  def down
    remove_column :protocol_merges, :identity_id
  end
end
