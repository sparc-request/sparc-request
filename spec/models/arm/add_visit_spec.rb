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
  describe '#add_visit' do
    let(:arm) { Arm.create(visit_count: 1, subject_count: 1, name: "My Good Arm") }

    context 'position not specified' do
      let!(:arm) { create(:arm, visit_count: 2, line_item_count: 2, name: "My Good Arm") }
      it 'should add a new VisitGroup to the end' do
        orig_vg_ids = arm.visit_groups.map &:id
        # expect change in number of VisitGroups
        expect { arm.add_visit }.to change { arm.visit_groups.count }.from(2).to(3)
        # expect first two VisitGroups to be preserved
        expect(arm.visit_groups.map &:id).to start_with orig_vg_ids
        # expect last VisitGroup to be new
        expect(orig_vg_ids).not_to include(arm.visit_groups[2].id)
      end

      it 'should increment visit_count' do
        expect { arm.add_visit }.to change { arm.visit_count }.by(1)
      end

      it 'should add a new Visit to each LineItemsVisit to the end' do
        liv0_visit_ids = arm.line_items_visits[0].visits.map &:id
        liv1_visit_ids = arm.line_items_visits[1].visits.map &:id

        arm.add_visit
        arm.reload

        # expect change in number of Visits on each LIV
        expect(arm.line_items_visits.map { |liv| liv.visits.count }).to eq [3, 3]

        expect(arm.line_items_visits[0].visits.map &:id).to start_with liv0_visit_ids
        expect(arm.line_items_visits[1].visits.map &:id).to start_with liv1_visit_ids
        expect(liv0_visit_ids.product liv1_visit_ids).not_to include(
          [arm.line_items_visits[0].visits[2], arm.line_items_visits[1].visits[2]])
      end
    end

    context 'position specified' do
      let!(:arm) { create(:arm, visit_count: 2, line_item_count: 2, name: "My Good Arm") }

      it 'should add a new VisitGroup to that position' do
        arm.visit_groups.last.update_attribute(:day, 3)
        expect { arm.add_visit 2 }.to change { arm.visit_groups.count }.by(1)
        expect(arm.visit_groups[1].id).to eq(VisitGroup.last.id)
      end

      it 'should add a new Visit to each LineItemsVisit to that position' do
        arm.visit_groups.last.update_attribute(:day, 3)
        liv0_visit_ids = arm.line_items_visits[0].visits.map &:id
        liv1_visit_ids = arm.line_items_visits[1].visits.map &:id

        arm.add_visit 2
        arm.reload

        # expect change in number of Visits on each LIV
        expect(arm.line_items_visits.map { |liv| liv.visits.count }).to eq [3, 3]

        # check order of Visits on each LIV
        expect(arm.line_items_visits[0].visits[0].id).to eq liv0_visit_ids[0]
        expect(arm.line_items_visits[0].visits[2].id).to eq liv0_visit_ids[1]
        expect(arm.line_items_visits[1].visits[0].id).to eq liv1_visit_ids[0]
        expect(arm.line_items_visits[1].visits[2].id).to eq liv1_visit_ids[1]

        # check placement of new Visits
        expect(liv0_visit_ids.product liv1_visit_ids).not_to include(
          [arm.line_items_visits[0].visits[1], arm.line_items_visits[1].visits[1]])
      end
    end

    context 'name specified' do
      it 'should set VisitGroup name' do
        arm = create(:arm)

        arm.add_visit(0, 0, 0, 0, 'Visit Group Name')
        
        expect(arm.visit_groups.first.name).to eq 'Visit Group Name'
      end
    end

    context 'USE_EPIC == true' do
      let(:arm) { create(:arm) }

      before(:each) do
        stub_const("USE_EPIC", true)
      end

      it 'should set new VisitGroup\'s day, window_before, and window_after' do
        expect(arm).to receive(:update_visit_group_day).with(:day, 9, :portal).and_return true
        expect(arm).to receive(:update_visit_group_window_before).with(:window_before, 9, :portal).and_return true
        expect(arm).to receive(:update_visit_group_window_after).with(:window_after, 9, :portal).and_return true


        arm.add_visit 10, :day, :window_before, :window_after, "Visit Group Name", :portal
      end
    end

    context 'USE_EPIC == false' do
      let(:arm) { create(:arm) }

      before(:each) do
        stub_const("USE_EPIC", false)
      end

      it 'should not set new VisitGroup\'s day, window_before, or window_after' do
        expect(arm).not_to receive(:update_visit_group_day)
        expect(arm).not_to receive(:update_visit_group_window_before)
        expect(arm).not_to receive(:update_visit_group_window_after)
        arm.add_visit 10, :day, :window_before, :window_after, "Visit Group Name", :portal
      end
    end
  end
end
