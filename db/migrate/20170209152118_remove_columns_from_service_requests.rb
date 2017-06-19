class RemoveColumnsFromServiceRequests < ActiveRecord::Migration[4.2]
  def change
    remove_column :service_requests, :subject_count, :integer
    remove_column :service_requests, :consult_arranged_date, :datetime
    remove_column :service_requests, :pppv_complete_date, :datetime
    remove_column :service_requests, :pppv_in_process_date, :datetime
  end
end
