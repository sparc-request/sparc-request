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
  describe '#mass_destroy_visit_group' do
    shared_examples_for 'no extra VisitGroups' do
      it 'should not remove any VisitGroups' do
        expect { arm.mass_destroy_visit_group }.not_to change { arm.visit_groups.size }
      end
    end

    context 'number of VisitGroups exceeds visit_count' do

      it 'should remove extra VisitGroups from the end' do
        arm = create(:arm, visit_count: 2, line_item_count: 1)
        arm.update_attributes(visit_count: 1)
        arm.reload
        first_vg_id = arm.visit_groups.first.id
        arm.mass_destroy_visit_group
        expect(arm.visit_groups.size).to eq(1)
        expect(arm.reload.visit_groups.first.id).to eq first_vg_id
      end
    end

    context 'number of VisitGroups same as visit_count' do
      let(:arm) { create(:arm, visit_count: 1, line_item_count: 1) }

      it_behaves_like 'no extra VisitGroups'
    end

    context 'visit_count exceeds number of VisitGroups' do
      let(:arm) do
        a = create(:arm, visit_count: 1, line_item_count: 1)
        a.update_attributes(visit_count: 2)
        a
      end

      it_behaves_like 'no extra VisitGroups'
    end
  end
end
