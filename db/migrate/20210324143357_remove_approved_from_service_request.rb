class RemoveApprovedFromServiceRequest < ActiveRecord::Migration[5.2]
  def change
    remove_column :service_requests, :approved
  end
end
