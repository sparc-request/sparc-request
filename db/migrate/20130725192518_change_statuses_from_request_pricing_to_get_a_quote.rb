class ChangeStatusesFromRequestPricingToGetAQuote < ActiveRecord::Migration
  def up
    ServiceRequest.where(status: 'obtain_research_pricing').each do |sr|
      sr.update_attributes(:status => 'get_a_quote')
    end
    PastStatus.where(status: 'obtain_research_pricing').each do |ps|
      ps.update_attributes(:status => 'get_a_quote')
    end
  end

  def down
    PastStatus.where(status: 'get_a_quote').each do |ps|
      ps.update_attributes(:status => 'obtain_research_pricing')
    end
    ServiceRequest.where(status: 'get_a_quote').each do |sr|
      sr.update_attributes(:status => 'obtain_research_pricing')
    end
  end
end
