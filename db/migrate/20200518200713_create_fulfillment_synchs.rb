class CreateFulfillmentSynchs < ActiveRecord::Migration[5.2]
  def change
    create_table :fulfillment_synchs do |t|
      t.references :SubServiceRequest
      t.integer    :line_item_id
      t.string     :action
      t.boolean    :synched, default: false
    end
  end
end
