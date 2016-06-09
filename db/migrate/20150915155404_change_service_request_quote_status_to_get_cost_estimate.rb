class ChangeServiceRequestQuoteStatusToGetCostEstimate < ActiveRecord::Migration
  def up
    [
      'ServiceRequest',
      'SubServiceRequest',
      'AvailableStatus',
      'PastStatus'
    ].each do |model|
      model.
        constantize.
        where(status: 'get_a_quote').
        update_all status: 'get_a_cost_estimate'
    end
  end

  def down
    [
      'ServiceRequest',
      'SubServiceRequest',
      'AvailableStatus',
      'PastStatus'
    ].each do |model|
      model.
        constantize.
        where(status: 'get_a_cost_estimate').
        update_all status: 'get_a_quote'
    end
  end
end
