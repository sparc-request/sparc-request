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
  describe '#populate_subjects' do
    context 'number of associated Subjects exceeds subject_count' do
      let!(:arm) { create(:arm, subject_count: 1) }
      before(:each) do
        2.times { arm.subjects.create }
      end

      it 'should not create any Subjects' do
        expect { arm.populate_subjects }.not_to change { arm.subjects.count }
      end
    end

    context 'number of associated Subjects equals subject_count' do
      let!(:arm) { create(:arm, subject_count: 1) }
      before(:each) do
        arm.subjects.create
      end

      it 'should not create any Subjects' do
        expect { arm.populate_subjects }.not_to change { arm.subjects.count }
      end
    end

    context 'subject_count exceeds number of associated Subjects' do
      let!(:arm) { create(:arm, subject_count: 3) }
      before(:each) do
        arm.subjects.create
      end

      it 'should create enough Subjects so that there are subject_count total' do
        expect { arm.populate_subjects }.to change { arm.subjects.count }.from(1).to(3)
      end
    end
  end
end
