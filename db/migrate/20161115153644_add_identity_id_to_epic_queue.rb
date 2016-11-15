class AddIdentityIdToEpicQueue < ActiveRecord::Migration
  def change
    add_column :epic_queues, :identity_id, :integer
  end
end
