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

RSpec.describe Arm, type: :model do
  describe '#maximum_indirect_costs_per_patient' do
    let!(:arm) { Arm.new() }
    let!(:livs) do
      [instance_double("LineItemsVisit", direct_costs_for_visit_based_service_single_subject: 3),
       instance_double("LineItemsVisit", direct_costs_for_visit_based_service_single_subject: 4),
       instance_double("LineItemsVisit", direct_costs_for_visit_based_service_single_subject: 5)]
    end

    before(:each) do
      allow(arm).to receive(:line_items_visits).and_return livs
      allow(arm).to receive_message_chain(:protocol, :indirect_cost_rate).and_return 50
    end

    context 'with USE_INDIRECT_COST' do
      before(:each) { stub_const('USE_INDIRECT_COST', true) }

      context 'with no argument' do
        it 'should return total indirect cost all LineItems' do
          expect(arm.maximum_indirect_costs_per_patient).to eq(arm.maximum_direct_costs_per_patient / 2.0)
        end
      end

      context 'with array of LineItemsVisits' do
        it 'should return total indirect cost for those LineItemsVisits' do
          expect(arm.maximum_indirect_costs_per_patient livs[0..1]).to eq(arm.maximum_direct_costs_per_patient(livs[0..1]) / 2.0)
        end
      end
    end

    context 'without USE_INDIRECT_COST' do
      context 'with no argument' do
        it 'should return total indirect cost all LineItems' do
          expect(arm.maximum_indirect_costs_per_patient).to eq 0.0
        end
      end

      context 'with array of LineItemsVisits' do
        it 'should return total indirect cost for those LineItemsVisits' do
          expect(arm.maximum_indirect_costs_per_patient livs[0..1]).to eq 0.0
        end
      end
    end
  end
end
