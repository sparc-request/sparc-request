# Copyright © 2011 MUSC Foundation for Research Development
# All rights reserved.

# Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:

# 1. Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.

# 2. Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following
# disclaimer in the documentation and/or other materials provided with the distribution.

# 3. Neither the name of the copyright holder nor the names of its contributors may be used to endorse or promote products
# derived from this software without specific prior written permission.

# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING,
# BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT
# SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
# DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
# INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR
# TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

class Subsidy < ActiveRecord::Base
  audited

  belongs_to :sub_service_request

  attr_accessible :sub_service_request_id
  attr_accessible :pi_contribution
  attr_accessible :stored_percent_subsidy
  attr_accessible :overridden
  attr_accessible :status
  attr_accessible :total_at_approval

  # validate :pi_contribution_cap, :stored_percent_subsidy_cap

  # def pi_contribution=(new_contribution)
  #   # recalculate subsidy percentage when changing contribution
  #   if new_contribution.present?
  #     write_attribute(:pi_contribution, new_contribution)
  #     write_attribute(:stored_percent_subsidy, percent_subsidy)
  #   end
  # end

  # def stored_percent_subsidy=(new_percent_subsidy)
  #   # recalculate contribution when changing subsidy percentage
  #   if new_percent_subsidy.present?
  #     write_attribute(:stored_percent_subsidy, new_percent_subsidy)
  #     write_attribute(:pi_contribution, contribution_with_subsidy)
  #   end
  # end

  def pi_contribution_cap
    #  (PI Contribution < max) validation
    if pi_contribution.present? and max_dollar_cap.present?
      if pi_contribution > max_dollar_cap
        errors.add(:pi_contribution, "is above the maximum contribution amount")
      end
    end
  end

  def stored_percent_subsidy_cap
    #  (stored percent subsidy < max) validation
    if stored_percent_subsidy.present? and max_percentage.present?
      if stored_percent_subsidy > max_percentage
        errors.add(:stored_percent_subsidy, "is above the maximum subsidy percentage")
      end
    end
  end

  def percent_subsidy
    if self.pi_contribution.nil?
      subsidy = 0.0
    else
      total = self.sub_service_request.direct_cost_total
      remainder = (total - self.pi_contribution)
      subsidy = (remainder / total)
    end

    subsidy.nan? ? nil : subsidy
  end

  def contribution_with_subsidy
    if self.stored_percent_subsidy.nil?
      contribution = 0
    else
      total = self.sub_service_request.direct_cost_total
      subsidized_amount = (stored_percent_subsidy * total) / 100.0
      contribution = (total - subsidized_amount)
    end

    contribution.nan? ? nil : contribution
  end

  def max_dollar_cap
    sub_service_request.organization.subsidy_map.max_dollar_cap
  end

  def max_percentage
    sub_service_request.organization.subsidy_map.max_percentage
  end

  def self.calculate_pi_contribution subsidy_percentage, total
    contribution = (total * (subsidy_percentage.to_f / 100.00)).ceil
    contribution = total - contribution
    contribution.nan? ? contribution : contribution.ceil
  end

  def fix_pi_contribution subsidy_percentage
    new_contribution = Subsidy.calculate_pi_contribution(subsidy_percentage, self.sub_service_request.direct_cost_total)
    self.update_attributes(:pi_contribution => new_contribution)

    new_contribution
  end

  def subsidy_audits
    subsidy_audits = AuditRecovery.where("auditable_id = ? AND auditable_type = ?", self.id, "Subsidy").order(:created_at)
    subsidy_audits
  end
end
