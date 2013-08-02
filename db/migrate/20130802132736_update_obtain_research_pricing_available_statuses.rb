class UpdateObtainResearchPricingAvailableStatuses < ActiveRecord::Migration
  def up
    AvailableStatus.where(:status => 'obtain_research_pricing').each do |as|
      as.update_attributes({:status => 'get_a_quote'})
    end
  end

  def down
    AvailableStatus.where(:status => 'get_a_quote').each do |as|
      as.update_attributes({:status => 'obtain_research_pricing'})
    end
  end
end
