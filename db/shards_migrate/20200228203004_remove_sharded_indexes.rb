class RemoveShardedIndexes < ActiveRecord::Migration[6.0]
  using_group(:shards)

  def change
    # These indexes cannot exist because the referenced records
    # could be stored in a different shard.

    if foreign_key_exists?(:sub_service_requests, :organizations)
      remove_foreign_key :sub_service_requests, :organizations
    end

    if index_exists?(:sub_service_requests, :organization_id)
      remove_index :sub_service_requests, :organization_id
    end

    if foreign_key_exists?(:line_items, :services)
      remove_foreign_key :line_items, :services
    end

    if index_exists?(:line_items, :service_id)
      remove_index :line_items, :service_id
    end
  end
end
