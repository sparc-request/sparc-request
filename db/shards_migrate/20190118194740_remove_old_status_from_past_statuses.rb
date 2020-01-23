class RemoveOldStatusFromPastStatuses < ActiveRecord::Migration[5.2]
  using_group(:shards)

  def change
    PastStatus.where(status: "obtain_research_pricing").update_all(status: "get_a_cost_estimate")

    PastStatus.where(new_status: "obtain_research_pricing").update_all(new_status: "get_a_cost_estimate")

    SubServiceRequest.where(status: "obtain_research_pricing").update_all(status: "get_a_cost_estimate")
  end
end
