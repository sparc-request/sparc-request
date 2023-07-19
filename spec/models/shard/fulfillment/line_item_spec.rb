# Copyright © 2011-2022 MUSC Foundation for Research Development~
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

RSpec.describe Shard::Fulfillment::LineItem, type: :model do
  describe 'associations' do
    it 'belongs to :sparc_line_item' do
      should belong_to(:sparc_line_item)
    end
    it 'belongs to :sparc_service' do
      should belong_to(:sparc_service)
    end
  end

  describe 'instance methods' do
    describe '#fulfilled?' do
      let(:service_id) { 1 }
      let(:procedure ) {{ status: 'incomplete' }}
       context 'if service is non-clinical' do
        it 'returns true' do
          allow(subject).to receive(:non_clinical?).and_return(true)
          allow(subject).to receive_message_chain(:fulfillments, :exists?).and_return(true)
          expect(subject.fulfilled?).to eq(true)
        end
      end
    end

    describe '#non_clinical?' do
      context 'when the line item is a one time fee' do
        it 'returns true' do
          allow(subject).to receive_message_chain(:sparc_line_item, :service, :one_time_fee?).and_return(true)
          expect(subject.non_clinical?).to eq(true)
        end
      end
    end

    describe '#deleted?' do
      context 'when the line item has been deleted' do
        it 'returns true' do
          allow(subject).to receive(:deleted_at).and_return(true)
          expect(subject.deleted?).to eq(true)
        end
      end
    end
  end
end
