class AddSubmittedAtToSubServiceRequest < ActiveRecord::Migration
  def change
    add_column :sub_service_requests, :submitted_at, :timestamp

    SubServiceRequest.all.each do |ssr|
      past_status = ssr.past_statuses.where(status: "submitted").order('date').last

      unless past_status.nil?
        ssr.update_attribute(:submitted_at, past_status.date)
      end
    end
  end
end
