class AddSubmittedAtToSubServiceRequest < ActiveRecord::Migration[4.2]
  def change
    add_column :sub_service_requests, :submitted_at, :timestamp

    SubServiceRequest.where(status: 'submitted').each do |ssr|
      past_status = ssr.past_statuses.order('date').last

      ssr.update_attribute(:submitted_at, past_status.date) unless past_status.nil?
    end

    SubServiceRequest.where.not(status: 'submitted').joins(:past_statuses).where(past_statuses: { status: 'submitted' }).each do |ssr|
      statuses = ssr.past_statuses
      changed_from_submitted_index = statuses.rindex{|past_status| past_status.status == 'submitted'}
      changed_to_submitted = statuses[(changed_from_submitted_index - 1)]

      ssr.update_attribute(:submitted_at, changed_to_submitted.date)
    end
  end
end
