class AddIdentityIdToEpicQueue < ActiveRecord::Migration
  def change
    add_reference(:epic_queues, :identity)
  end
end
