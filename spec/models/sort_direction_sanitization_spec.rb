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

RSpec.describe 'Sort direction SQL injection protection', type: :model do
  let(:payload) { "ASC, (SELECT IF(1=1, SLEEP(5), 0))" }

  describe 'ApplicationRecord.sanitize_sort_direction' do
    it 'allows asc and desc case-insensitively' do
      expect(ApplicationRecord.sanitize_sort_direction('ASC')).to eq(:asc)
      expect(ApplicationRecord.sanitize_sort_direction('desc')).to eq(:desc)
    end

    it 'falls back to the default on invalid or malicious input' do
      expect(ApplicationRecord.sanitize_sort_direction(payload, default: :desc)).to eq(:desc)
      expect(ApplicationRecord.sanitize_sort_direction(nil, default: :asc)).to eq(:asc)
    end
  end

  it 'neutralizes malicious order input in Protocol.sorted' do
    sql = Protocol.sorted('short_title', payload).to_sql
    expect(sql).to include("TRIM(REPLACE(short_title, CHAR(9), ' ')) DESC")
    expect(sql).not_to include('SLEEP')
  end

  it 'neutralizes malicious order input across the other 6 scopes' do
    [
      Identity.sorted('name', payload),
      Identity.overlords_sorted('email', payload),
      PermissibleValue.sorted('default', payload),
      Setting.sorted('group', payload),
      EpicQueue.ordered('protocol', payload),
      EpicQueueRecord.ordered('status', payload)
    ].each do |relation|
      expect(relation.to_sql).not_to include('SLEEP')
    end
  end
end