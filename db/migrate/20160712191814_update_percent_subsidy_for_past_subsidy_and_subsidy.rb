# Copyright © 2011-2016 MUSC Foundation for Research Development~
# All rights reserved.~

# Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:~

# 1. Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.~

# 2. Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following~
# disclaimer in the documentation and/or other materials provided with the distribution.~

# 3. Neither the name of the copyright holder nor the names of its contributors may be used to endorse or promote products~
# derived from this software without specific prior written permission.~

# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING,~
# BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT~
# SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL~
# DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS~
# INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR~
# TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.~

# Percent subsidy is held.
# Calculating percent subsidy based on pi contribution for both
# PastSubsidy and Subsidy tables
class UpdatePercentSubsidyForPastSubsidyAndSubsidy < ActiveRecord::Migration
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

  def change
    add_column :past_subsidies, :percent_subsidy, :float, default: 0

    PastSubsidy.reset_column_information

    PastSubsidy.all.each do |subsidy|
      pi_contribution = subsidy.pi_contribution
      request_cost = subsidy.total_at_approval
      if request_cost && pi_contribution && !request_cost.zero?
        percent_subsidy = (request_cost - pi_contribution).to_f / request_cost.to_f
        subsidy.update_attribute(:percent_subsidy, percent_subsidy)
      else
        puts "Percent Subsidy for #{subsidy.id} wasn't updated in PastSubsidy table"
      end
    end

    Subsidy.all.each do |subsidy|
      pi_contribution = subsidy.pi_contribution
      request_cost = subsidy.total_at_approval
      if request_cost && pi_contribution && !request_cost.zero?
        percent_subsidy = (request_cost - pi_contribution).to_f / request_cost.to_f
        subsidy.update_attribute(:percent_subsidy, percent_subsidy)
      elsif request_cost && pi_contribution && request_cost.zero? && pi_contribution.zero?
        puts "Request cost and pi contribution are both 0 for Subsidy #{subsidy.id}"
      else
        puts "Percent Subsidy for #{subsidy.id} wasn't updated in Subsidy table"
      end
    end
    remove_column :past_subsidies, :pi_contribution
    remove_column :subsidies, :pi_contribution
  end
end
