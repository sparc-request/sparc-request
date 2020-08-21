class AddSynchToFulfillmentToSubServiceRequest < ActiveRecord::Migration[5.2]
  def change
    add_column :sub_service_requests, :synch_to_fulfillment, :boolean
  end
end
