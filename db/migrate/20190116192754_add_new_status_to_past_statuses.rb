class AddNewStatusToPastStatuses < ActiveRecord::Migration[5.2]
  def change
    add_column :past_statuses, :new_status, :string

    progress_bar = ProgressBar.new(PastStatus.count)
    PastStatus.find_each(batch_size: 500) do |past_status|
      #Clean up past statuses that reference a missing sub_service_request
      if past_status.sub_service_request.nil?
        past_status.destroy
        progress_bar.increment!
        next
      end

      PastStatus.where(sub_service_request_id: past_status.sub_service_request_id).reorder(date: :desc, id: :desc).each_with_index do |sibling_past_status, index|
        if index == 0
          #Use current ssr status to fill in the most recent past_status's "new status"
          sibling_past_status.update_attribute(:new_status, sibling_past_status.sub_service_request.status)
        else
          #Otherwise use variable that will have been created on the previous loop
          sibling_past_status.update_attribute(:new_status, @new_status)
        end
        #Set variable for next descending past_status to use
        @new_status = sibling_past_status.status
      end
      progress_bar.increment!
    end
  end
end
