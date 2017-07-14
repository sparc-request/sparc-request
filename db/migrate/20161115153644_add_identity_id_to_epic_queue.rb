class AddIdentityIdToEpicQueue < ActiveRecord::Migration[4.2]
  def change
    add_reference(:epic_queues, :identity)
  end
end
