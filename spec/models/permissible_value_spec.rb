# Copyright © 2011-2019 MUSC Foundation for Research Development
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

RSpec.describe PermissibleValue, type: :model do

  # Scopes
  describe '#available' do
    it 'should return only available PermissibleValues' do
      pv_avail    = create(:permissible_value, is_available: true)
      pv_unavail  = create(:permissible_value, is_available: false)

      expect(PermissibleValue.available.include?(pv_avail)).to eq(true)
      expect(PermissibleValue.available.include?(pv_unavail)).to eq(false)
    end
  end

  describe '#unavailable' do
    it 'should return only unavailable PermissibleValues' do
      pv_avail    = create(:permissible_value, is_available: true)
      pv_unavail  = create(:permissible_value, is_available: false)

      expect(PermissibleValue.unavailable.include?(pv_unavail)).to eq(true)
      expect(PermissibleValue.unavailable.include?(pv_avail)).to eq(false)
    end
  end

  # Class methods
  context 'get_value' do
    it 'should return the first value with the given key and category' do
      pv = create(:permissible_value, category: 'category', key: 'key1')
           create(:permissible_value, category: 'category', key: 'key2')
      expect(PermissibleValue.get_value('category', 'key1')).to eq(pv.value)
    end
  end

  context 'get_key_list' do
    before :all do
      @pv1 = create(:permissible_value, key: 'key1', category: 'first', default: true)
      @pv2 = create(:permissible_value, key: 'key2', category: 'first', default: true)
      @pv3 = create(:permissible_value, key: 'key3', category: 'first', default: false)
             create(:permissible_value, key: 'key4', category: 'second', default: true)
    end

    it 'should return an array of keys if default is nil' do
      expect(PermissibleValue.get_key_list('first')).to eq([@pv1.key, @pv2.key, @pv3.key])
    end

    it 'should return an array of keys where default is true' do
      expect(PermissibleValue.get_key_list('first', true)).to eq([@pv1.key, @pv2.key])
    end
  end
end
