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

RSpec.describe Fulfillment, type: :model do
  describe '#formatted_date' do
    context 'date present' do
      let!(:fulfillment) { Fulfillment.create(date: Date.new(2001, 1, 2).strftime("%m/%d/%Y")) }
      it 'should return date in format: m/%d/%Y' do
        expect(fulfillment.date.strftime("%m/%d/%Y")).to eq '01/02/2001'
      end
    end

    context 'date not present' do
      it 'should return nil' do
        fulfillment = build(:fulfillment, date: nil)
        expect(fulfillment).not_to be_valid
      end
    end
  end

  describe '#within_date_range?' do
    context 'start_date nil' do
      let!(:fulfillment) { Fulfillment.create(date: Date.new(2001, 1, 2).strftime("%m/%d/%Y")) }
      it 'should return false' do
        expect(fulfillment.within_date_range?(nil, Date.new(2002, 1, 2))).to eq false
      end
    end

    context 'end_date nil' do
      let!(:fulfillment) { Fulfillment.create(date: Date.new(2001, 1, 2).strftime("%m/%d/%Y")) }
      it 'should return false' do
        expect(fulfillment.within_date_range?(Date.new(2000, 1, 2), nil)).to eq false
      end
    end

    context 'date nil' do
      let!(:fulfillment) { Fulfillment.create(date: nil) }
      it 'should return false' do
        expect(fulfillment.within_date_range?(Date.new(2000, 1, 2), Date.new(2001, 1, 2))).to eq false
      end
    end

    context 'start_date, end_date, and date are not nil' do
      let!(:fulfillment) { Fulfillment.create(date: nil) }
      before(:each) { @dates = [Date.new(2000, 1, 2), Date.new(2001, 1, 2), Date.new(2002, 1, 2)] * 2 }

      it 'should return true if Fulfillment date occurs on or after start date and occurs on or before end_date' do
        @dates.combination(3) do |start_date, date, end_date|
          fulfillment.update_attributes(date: date.strftime("%m/%d/%Y"))
          expect(fulfillment.within_date_range?(start_date, end_date)).to eq(
            (date >= start_date) && (date <= end_date))
        end
      end
    end
  end

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
