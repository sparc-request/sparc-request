class AddRoutingToSubServiceRequest < ActiveRecord::Migration
  def change
    add_column :sub_service_requests, :routing, :string
  end
end
