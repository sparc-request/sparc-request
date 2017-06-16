class AddIdentityIdToEpicQueue < ActiveRecord::Migration[5.1]
  def change
    add_reference(:epic_queues, :identity)
  end
end
