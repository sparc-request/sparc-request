class CreateFulfillmentSynchs < ActiveRecord::Migration[5.2]
  def change
    create_table :fulfillment_synchronizations do |t|
      t.references :sub_service_request
      t.integer    :line_item_id
      t.string     :action
      t.boolean    :synched, default: false
    end
  end
end
