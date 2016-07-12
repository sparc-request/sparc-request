class Subsidy < ActiveRecord::Base
  attr_accessible :percent_subsidy
  attr_accessible :pi_contribution
  attr_accessible :total_at_approval
end

class PastSubsidy < ActiveRecord::Base
  attr_accessible :percent_subsidy
  attr_accessible :pi_contribution
  attr_accessible :total_at_approval
end

# Percent subsidy is held.
# Calculating percent subsidy based on pi contribution for both
# PastSubsidy and Subsidy tables
class UpdatePercentSubsidyForPastSubsidyAndSubsidy < ActiveRecord::Migration
  def change
    add_column :past_subsidies, :percent_subsidy, :float, default: 0
    PastSubsidy.all.each do |subsidy|
      pi_contribution = subsidy.pi_contribution
      request_cost = subsidy.total_at_approval
      percent_subsidy = (request_cost - pi_contribution).to_f / request_cost.to_f
      subsidy.update_attribute(:percent_subsidy, percent_subsidy)
    end

    Subsidy.all.each do |subsidy|
      pi_contribution = subsidy.pi_contribution
      request_cost = subsidy.total_at_approval
      if request_cost && pi_contribution && !request_cost.zero?
        percent_subsidy = (request_cost - pi_contribution).to_f / request_cost.to_f
        subsidy.update_attribute(:percent_subsidy, percent_subsidy)
      end
    end
    remove_column :past_subsidies, :pi_contribution
    remove_column :subsidies, :pi_contribution
  end
end
