class ChangeServiceRequestQuoteStatusToGetCostEstimate < ActiveRecord::Migration
  def up
    ServiceRequest.where(status: 'get_a_quote').update_all status: 'get_a_cost_estimate'
  end

  def down
    ServiceRequest.where(status: 'get_a_cost_estimate').update_all status: 'get_a_quote'
  end
end
