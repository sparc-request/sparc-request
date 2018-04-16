class CorrectAvailableStatuses < ActiveRecord::Migration[5.1]
  def change
    statuses = availableStatus.where(status: ['draft', 'get_a_cost_estimate', 'submitted'], selected: false)
    statuses.each do |status|
      status.update_attributes(selected: true)
    end
  end
end
