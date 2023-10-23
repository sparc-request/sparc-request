class AddRecentSubmittedByToSsr < ActiveRecord::Migration[5.2]
  def change
    add_column :sub_service_requests, :recent_submitted_by, :bigint, after: :submitted_at
    add_index :sub_service_requests, :recent_submitted_by

    SubServiceRequest.where.not(submitted_at: nil).each do |ssr|
      last_submitted_status = ssr.past_status_lookup.select { |ps| ps.new_status == 'submitted' }.last
      if last_submitted_status
        ssr.update(recent_submitted_by: last_submitted_status.changed_by_id)
      end
    end

  end
end
