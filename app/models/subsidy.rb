class Subsidy < ActiveRecord::Base
  #Version.primary_key = 'id'
  #has_paper_trail

  belongs_to :sub_service_request

  attr_accessible :sub_service_request_id
  attr_accessible :pi_contribution
  attr_accessible :overridden

  def percent_subsidy
    if self.pi_contribution.nil?
      subsidy = 0.0
    else
      total = self.sub_service_request.direct_cost_total
      subsidy = total - self.pi_contribution
      subsidy = subsidy / total
    end
    subsidy.nan? ? nil : subsidy
  end

  def self.calculate_pi_contribution subsidy_percentage, total
    contribution = total * (subsidy_percentage.to_f / 100.0)
    contribution = total - contribution
    contribution.nan? ? contribution : contribution.ceil
  end

  def fix_pi_contribution subsidy_percentage
    new_contribution = Subsidy.calculate_pi_contribution(subsidy_percentage, self.sub_service_request.direct_cost_total)
    self.update_attributes(:pi_contribution => new_contribution)
  end
  
end