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

module SubsidiesHelper

  def display_requested_funding direct_cost, contribution
    # multiply contribution by 100 to convert to cents
    rf = direct_cost - contribution rescue 0
    currency_converter(rf)
  end

  def calculate_subsidy_percentage direct_cost, contribution, subsidy
    # multiply contribution by 100 to convert to cents
    percentage = 0.0
    unless subsidy.overridden
      return 0 if direct_cost == 0.0
      funded_amount = direct_cost - contribution rescue 0
      percentage = ((funded_amount / direct_cost) * 100).round(2)
    else
      percentage = subsidy.stored_percent_subsidy
    end

    percentage
  end

  def calculate_pi_contribution subsidy, direct_cost
    contribution = 0.0

    if !subsidy.overridden
      if direct_cost == 0.0
        contribution = nil
        subsidy.update_attributes(:stored_percent_subsidy => 0.0)
        subsidy.update_attributes(:pi_contribution => nil)
      elsif direct_cost != 0.0 && subsidy.stored_percent_subsidy != 0.0    
        percent_subsidy = subsidy.stored_percent_subsidy
        contribution = (direct_cost * (percent_subsidy / 100.00)).ceil
        contribution = direct_cost - contribution
        subsidy.update_attributes(:pi_contribution => contribution)
      elsif direct_cost != 0.0 && subsidy.stored_percent_subsidy == 0.0
        contribution = nil
        subsidy.update_attributes(:pi_contribution => nil)
      end
    else
      percent_subsidy = subsidy.stored_percent_subsidy
      contribution = (direct_cost * (percent_subsidy / 100.00)).ceil
      contribution = direct_cost - contribution
      subsidy.update_attributes(:pi_contribution => contribution)
    end

    contribution
  end
end
