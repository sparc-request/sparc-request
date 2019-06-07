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

RSpec.describe Setting, data_type: :model do
    
  it 'should have a valid factory' do
    expect(build(:setting)).to be_valid
  end

  it { is_expected.to validate_uniqueness_of(:key) }
  it { is_expected.to validate_presence_of(:data_type) }
  it { is_expected.to validate_inclusion_of(:data_type).in_array(%w(boolean string json email url path)) }

  describe '#value_matches_type' do
    context '#data_type == boolean' do
      it 'should return true if valid' do
        expect(build(:setting, :boolean)).to be_valid
      end

      it 'should return false if invalid' do
        expect(build(:setting, data_type: 'boolean', value: 'faux')).to_not be_valid
      end
    end

    context '#data_type == json' do
      it 'should return true if valid' do
        expect(build(:setting, :json)).to be_valid
      end

      it 'should return false if invalid' do
        expect(build(:setting, data_type: 'json', value: '{key: "value"}')).to_not be_valid
      end
    end

    context '#data_type == email' do
      it 'should return true if valid' do
        expect(build(:setting, :email)).to be_valid
      end

      it 'should return false if invalid' do
        expect(build(:setting, data_type: 'email', value: 'my.email.us')).to_not be_valid
      end
    end

    context '#data_type == url' do
      it 'should return true if valid' do
        expect(build(:setting, :url)).to be_valid
      end

      it 'should return false if invalid' do
        expect(build(:setting, data_type: 'url', value: '/dashboard/protocols/')).to_not be_valid
      end
    end

    context '#data_type == path' do
      it 'should return true if valid' do
        expect(build(:setting, :path)).to be_valid
      end

      it 'should return false if invalid' do
        expect(build(:setting, data_type: 'path', value: 'https://sparc.musc.edu/dashboard/protocols/')).to_not be_valid
      end
    end
  end
end
