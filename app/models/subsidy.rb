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
  has_many :notes, as: :notable

  attr_accessible :sub_service_request_id
  attr_accessible :pi_contribution
  attr_accessible :overridden
  attr_accessible :status

  delegate :organization, to: :sub_service_request, allow_nil: true
  delegate :subsidy_map, to: :organization, allow_nil: true
  delegate :max_dollar_cap, to: :subsidy_map, allow_nil: true
  delegate :max_percentage, to: :subsidy_map, allow_nil: true

  delegate :direct_cost_total, to: :sub_service_request, allow_nil: true
  alias_attribute :total_request_cost, :direct_cost_total

  validates_presence_of :pi_contribution
  validate :contribution_caps

  def contribution_caps
    # Contribution can not be less than 0, greater than total, or greater than cap (if cap)
    cap = max_dollar_cap
    if pi_contribution < 0
      errors.add(:pi_contribution, "can not be less than 0")
    elsif cap.present? and cap > 0 and pi_contribution > cap
      errors.add(:pi_contribution, "can not be greater than the cap of #{cap}")
    elsif pi_contribution > total_request_cost
      errors.add(:pi_contribution, "can not be greater than the total request cost")
    end
  end

  def contribution_percent_of_cost
    # This is basically (1 - %subsidy)
    pi_contribution.present? ? (pi_contribution.to_f / total_request_cost * 100.0).round(2) : nil
  end

  def subsidy_audits
    subsidy_audits = AuditRecovery.where("auditable_id = ? AND auditable_type = ?", self.id, "Subsidy").order(:created_at)
    subsidy_audits
  end
end
