class AddDatesToSubServiceRequest < ActiveRecord::Migration
  def change
    add_column :sub_service_requests, :consult_arranged_date, :datetime
    add_column :sub_service_requests, :requester_contacted_date, :datetime
  end
end
