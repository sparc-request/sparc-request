class CorrectAvailableStatuses < ActiveRecord::Migration[5.1]
  def change
    statuses = AvailableStatus.where(status: ['draft', 'get_a_cost_estimate', 'submitted'], selected: false).update_all(status:true)
  end
end
