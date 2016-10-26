# Copyright © 2011-2016 MUSC Foundation for Research Development
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

class PastSubsidy < ActiveRecord::Base
  audited

  belongs_to :sub_service_request
  belongs_to :approver, class_name: 'Identity', foreign_key: "approved_by"

  attr_accessible :sub_service_request_id
  attr_accessible :total_at_approval
  attr_accessible :percent_subsidy
  attr_accessible :approved_by
  attr_accessible :approved_at

  default_scope { order('approved_at ASC') }

  def pi_contribution
    # This ensures that if pi_contribution is null (new record),
    # then it will reflect the full cost of the request.
    total_at_approval.to_f - (total_at_approval.to_f * percent_subsidy) || total_at_approval.to_f
  end

  def approved_cost
    # Calculates cost of subsidy (amount subsidized)
    # stored total - pi_contribution then convert from cents to dollars
    ( total_at_approval.to_f - pi_contribution ) / 100.0
  end

  def approved_percent_of_total
    # Calculates the percent of total_at_approval that is subsidized
    # (stored total - pi_contribution) / stored total then convert to percent
    total = total_at_approval.to_f

    if total.nil? || total == 0
      0.00
    else
      ((( total - pi_contribution ).to_f / total ) * 100.0 ).round(2)
    end
  end
end
