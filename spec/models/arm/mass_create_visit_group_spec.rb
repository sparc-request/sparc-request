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
  describe '#mass_create_visit_group' do
    let(:arm) { create(:arm, visit_count: 2, line_item_count: 2) }

    before(:each) do
      arm.update(visit_count: 5)
      arm.reload
    end

    it 'should add VisitGroups to Arm until the number of VisitGroups equals visit_count' do
      expect { arm.mass_create_visit_group }.to change { arm.visit_groups.count }.from(2).to(5)
    end

    it 'should add new VisitGroups with incrementing positions beginning at last_position + 1' do
      last_position = arm.visit_groups.last.position
      old_vg_ids    = arm.visit_groups.pluck :id
      arm.mass_create_visit_group
      new_positions = arm.visit_groups.where.not(id: old_vg_ids).pluck(:position)
      expect(new_positions).to eq ((last_position+1)..(last_position+3)).to_a
    end

    it 'should add Visits to newly created VisitGroups' do
      old_vg_ids    = arm.visit_groups.pluck :id
      arm.mass_create_visit_group
      visit_counts_for_new_vgs = arm.visit_groups.where.not(id: old_vg_ids).map { |vg| vg.visits.count }
      expect(visit_counts_for_new_vgs).to eq [2, 2, 2]
    end
  end
end
