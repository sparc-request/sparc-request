class CorrectAvailableStatuses < ActiveRecord::Migration[5.1]
  def change
    statuses = (AvailableStatus.where(status: "draft").or(AvailableStatus.where(status: "get_a_cost_estimate")).or(AvailableStatus.where(status: "submitted"))).where(selected: false)
    statuses.each do |status|
      status.update_attributes(selected: true)
    end
  end
end
