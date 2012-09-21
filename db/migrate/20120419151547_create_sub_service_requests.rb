class CreateSubServiceRequests < ActiveRecord::Migration
  def change
    create_table :sub_service_requests do |t|
      t.integer :service_request_id
      t.integer :organization_id
      t.integer :owner_id
      t.string :ssr_id
      t.datetime :status_date
      t.string :status

      t.timestamps
    end

    add_index :sub_service_requests, :service_request_id
    add_index :sub_service_requests, :organization_id
  end
end
