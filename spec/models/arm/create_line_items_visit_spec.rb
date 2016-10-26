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
  describe '#create_line_items_visit' do
    let!(:service_request) { create(:service_request_without_validations) }
    let!(:line_item)       { create(:line_item_with_service, service_request: service_request) }

    context 'visit_count is nil' do
      it 'should set visit_count to 1' do
        arm = create(:arm_without_validations, visit_count: nil)
        arm.create_line_items_visit line_item
        expect(arm.visit_count).to eq 1
      end
    end

    context 'visit_count is positive' do
      it 'should create enough VisitGroups to match visit_count' do
        arm = create(:arm, visit_count: 2, subject_count: 1)

        arm.create_line_items_visit(line_item)

        expect(arm.visit_groups.count).to eq(2)
      end

      it 'should create a LineItemsVisit for LineItem with new Visits' do
        arm = create(:arm, visit_count: 2, subject_count: 1)

        arm.create_line_items_visit(line_item)

        expect(arm.line_items_visits.count).to eq(1)
        liv = arm.reload.line_items_visits.first
        expect(liv.line_item).to              eq line_item
        expect(liv.subject_count).to          eq arm.subject_count
        expect(liv.visits.count).to           eq arm.visit_count
        expect(liv.visits.map(&:position)).to eq (1..arm.visit_count).to_a
      end

      context 'Arm has the same number of VisitGroups as visit_count' do
        it 'should not create any VisitGroups' do
          arm = create(:arm, visit_count: 2, subject_count: 1)
          create(:visit_group, name: 'Visit Group 1', position: 1, day: 1, arm: arm)
          create(:visit_group, name: 'Visit Group 2', position: 2, day: 2, arm: arm)
          arm.reload
          expect { arm.create_line_items_visit line_item }.to_not change { arm.visit_groups.count }
        end
      end

      context 'Arm has more VisitGroups than visit_count' do
        it 'should not create any VisitGroups' do
          arm = create(:arm, visit_count: 2, subject_count: 1)
          create(:visit_group, name: 'Visit Group 1', position: 1, day: 1, arm: arm)
          create(:visit_group, name: 'Visit Group 2', position: 2, day: 2, arm: arm)
          create(:visit_group, name: 'Visit Group 3', position: 3, day: 3, arm: arm)
          arm.reload
          
          expect { arm.create_line_items_visit line_item }.to_not change { arm.visit_groups.count }
        end
      end
    end
  end
end