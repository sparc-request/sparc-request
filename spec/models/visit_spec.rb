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

require 'rails_helper'

RSpec.describe 'Visit' do

  let_there_be_lane
  let_there_be_j
  build_service_request_with_study

  let!(:arm)               { create(:arm) }
  let!(:line_items_visit1) { create(:line_items_visit, arm_id: arm.id, line_item_id: line_item.id) }
  let!(:visit_group)       { create(:visit_group, arm_id: arm.id)}
  let!(:visit1)            { create(:visit, line_items_visit_id: line_items_visit1.id, visit_group_id: visit_group.id) }

  describe 'quantities customized' do

    it 'should return false if the quantities are untouched, or set to the default checked state' do
      expect(visit1.quantities_customized?).to eq(false)
      visit1.update_attributes(research_billing_qty: 1)
      expect(visit1.quantities_customized?).to eq(false)
    end

    it 'should return true if any of the quantities are set by the user' do
      visit1.update_attributes(research_billing_qty: 2, insurance_billing_qty: 1, effort_billing_qty: 1)
      expect(visit1.quantities_customized?).to eq(true)
    end
  end
end