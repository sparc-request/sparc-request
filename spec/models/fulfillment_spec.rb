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

RSpec.describe Fulfillment, type: :model do
  it { is_expected.to validate_presence_of :date }
  it { is_expected.to validate_presence_of :time }
  it { is_expected.to validate_presence_of :timeframe }

  describe 'time validation' do
    it 'should validate the format of time' do
      fulfillment = build(:fulfillment, date: Date.new(2001, 1, 2).strftime("%m/%d/%Y"), time: 1.23)

      expect(fulfillment).to be_valid
    end

    it 'should not validate the format of time up to two numbers after decimal point' do
      fulfillment = build(:fulfillment, date: Date.new(2001, 1, 2).strftime("%m/%d/%Y"), time: 1.23434)

      expect(fulfillment).not_to be_valid
    end

    it 'should not validate the format of time - should be greater than zero' do
      fulfillment = build(:fulfillment, date: Date.new(2001, 1, 2).strftime("%m/%d/%Y"), time: 0)

      expect(fulfillment).not_to be_valid
    end

    it 'should not validate the format of time - no strings allowed' do
      fulfillment = build(:fulfillment, date: Date.new(2001, 1, 2).strftime("%m/%d/%Y"), time: 'ooga booga')

      expect(fulfillment).not_to be_valid
    end
  end
end
