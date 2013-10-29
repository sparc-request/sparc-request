class AddFulfillmentFlagToSsr < ActiveRecord::Migration
  def change
  	add_column :sub_service_requests, :in_work_fulfillment, :boolean
  end
end
