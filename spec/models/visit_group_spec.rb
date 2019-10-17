# Copyright © 2011-2019 MUSC Foundation for Research Development
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

RSpec.describe VisitGroup, type: :model do

  let_there_be_lane
  let_there_be_j
  let!(:visit_group) { create(:visit_group, :with_arm, position: 1, day: 1)}
  let!(:visit1)      { create(:visit, visit_group_id: visit_group.id)}         
  let!(:visit2)      { create(:visit, visit_group_id: visit_group.id)}         

  describe 'valid visit' do
    context 'name' do
      it 'should not be nil' do
        visit_group = build(:visit_group, :with_arm, name: nil)
        visit_group.save

        expect(visit_group.errors.messages[:name].blank?).to eq(false)
      end
    end

    context 'position' do
      it 'should not be nil' do
        visit_group = build(:visit_group, :with_arm, position: nil)
        visit_group.save

        expect(visit_group.errors.messages[:position].blank?).to eq(false)
      end
    end

    context 'window_before' do
      it 'should be a number' do
        visit_group = build(:visit_group, :with_arm, window_before: 'string')
        visit_group.save

        expect(visit_group.errors.messages[:window_before].blank?).to eq(false)
      end

      it 'should not allow negative numbers' do
        visit_group = build(:visit_group, :with_arm, window_before: -1)
        visit_group.save

        expect(visit_group.errors.messages[:window_before].blank?).to eq(false)
      end

      it 'should not allow fractions' do
        visit_group = build(:visit_group, :with_arm, window_before: 2.7)
        visit_group.save

        expect(visit_group.errors.messages[:window_before].blank?).to eq(false)
      end
    end

    context 'window_after' do
      it 'should be a number' do
        visit_group = build(:visit_group, :with_arm, window_after: 'string')
        visit_group.save

        expect(visit_group.errors.messages[:window_after].blank?).to eq(false)
      end

      it 'should not allow negative numbers' do
        visit_group = build(:visit_group, :with_arm, window_after: -1)
        visit_group.save

        expect(visit_group.errors.messages[:window_after].blank?).to eq(false)
      end

      it 'should not allow fractions' do
        visit_group = build(:visit_group, :with_arm, window_after: 2.7)
        visit_group.save

        expect(visit_group.errors.messages[:window_after].blank?).to eq(false)
      end
    end

    context 'day' do
      it 'should not be nil' do
        visit_group = build(:visit_group, :with_arm, day: nil)
        visit_group.save

        expect(visit_group.errors.messages[:day]).to be
      end

      it 'should not allow fractions' do
        visit_group = build(:visit_group, :with_arm, day: 2.7)
        visit_group.save

        expect(visit_group.errors.messages[:day]).to be
      end
    end
  end
end
