class ChangeStatusesFromRequestPricingToGetAQuote < ActiveRecord::Migration
  def up
    ServiceRequest.where(status: 'obtain_research_pricing').update_attributes(:status => 'get_a_quote')
    PastStatus.where(status: 'obtain_research_pricing').update_attributes(:status => 'get_a_quote')
  end

  def down
    PastStatus.where(status: 'get_a_quote').update_attributes(:status => 'obtain_research_pricing')
    ServiceRequest.where(status: 'get_a_quote').update_attributes(:status => 'obtain_research_pricing')
  end
end
