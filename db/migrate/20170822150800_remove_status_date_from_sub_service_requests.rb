class RemoveStatusDateFromSubServiceRequests < ActiveRecord::Migration[5.1]
  def change
    remove_column :sub_service_requests, :status_date, :datetime
  end
end
