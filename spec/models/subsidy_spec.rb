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

require 'rails_helper'

RSpec.describe "Subsidy" do

  let_there_be_lane
  let_there_be_j
  build_service_request_with_study

  describe "#contribution_caps" do
    context "pi contribution is less than 0" do
      it "should return an error message" do
        subsidy.update_attribute(:percent_subsidy, 1.02)
        expect(subsidy.contribution_caps).to eq(["can not be less than 0"])
      end
    end
    context "subsidy cost is greater than max_dollar_cap" do
      # subsidy_cost = (request_cost - pi_contribution)
      # subsidy_cost = (5000 - 1000)
      # (subsidy_cost / 100.0) > dollar_cap
      # (4000 / 100) > 30
      it "should return an error message" do
        subsidy.update_attribute(:percent_subsidy, 0.7)
        subsidy_map.update_attribute(:max_dollar_cap, 30)
        expect(subsidy.contribution_caps).to eq(["can not be greater than the cap of 30.0"])
      end
    end
    context "percent_subsidy is greater than max_percentage" do
      # percent_subsidy * 100 > percent_cap
      # 0.4 * 100 > 30
      it "should return an error message" do
        subsidy.update_attribute(:percent_subsidy, 0.4)
        subsidy_map.update_attribute(:max_percentage, 30)
        expect(subsidy.contribution_caps).to eq(["can not be greater than the cap of 30.0"])
      end
    end
    context "pi_contribution is greater than total_request_cost" do
      # pi_contribution > total_request_cost
      # 1000 > 5000
      it "should return an error message" do
        subsidy.update_attribute(:percent_subsidy, -1)
        expect(subsidy.contribution_caps).to eq(["can not be greater than the total request cost"])
      end
    end
  end

 # TO DO:  write specs for #subsidy_audits
end
