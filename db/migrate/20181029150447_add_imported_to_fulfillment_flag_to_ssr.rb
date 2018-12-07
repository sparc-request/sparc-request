class AddImportedToFulfillmentFlagToSsr < ActiveRecord::Migration[5.2]
  def change
    add_column :sub_service_requests, :imported_to_fulfillment, :boolean, default: false

    SubServiceRequest.in_work_fulfillment.update_all imported_to_fulfillment: true
  end
end
