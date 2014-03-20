class AddIndexToSubServiceRequests < ActiveRecord::Migration
  def change
    add_index :sub_service_requests, :status
  end
end
