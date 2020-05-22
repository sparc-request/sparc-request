class AddSharingAttributesToServices < ActiveRecord::Migration[6.0]
  using_group(:shards)

  def change
    # Add an `organization_shard` column to sub_service_requests and default it to
    # the current shard's identifier
    add_column :sub_service_requests, :organization_shard,  :string,  after: :organization_id,  default: ActiveRecord::Base.connection.current_shard
    add_column :services,             :share_externally,    :boolean, after: :is_available,     default: true
  end
end
