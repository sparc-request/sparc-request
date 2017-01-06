# Copyright © 2011 MUSC Foundation for Research Development
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

RSpec.describe Arm, type: :model do
  before(:each) do
    @protocol = create(:protocol_without_validations)
  end

  context 'Name validations' do
    it 'must not have a blank name' do
      arm = build(:arm, protocol: @protocol)
      arm.name = ''

      expect(arm.valid?).to eq(false)
      expect(arm.errors.full_messages[0]).to eq("Arm Name can't be blank")
    end

    it 'must not contain: [ ] * / \\ ? :' do
      arm = build(:arm, protocol: @protocol)
      arm.name = '[ ] * \\ / ? :'

      expect(arm.valid?).to eq(false)
      expect(arm.errors.full_messages[0]).to eq("Arm Name can not contain any of the following characters: [ ] * / \\ ? : ")
    end

    # it 'may contain numbers, letters, and other special characters' do
    #   arm = build(:arm, protocol: @protocol)
    #   arm.name = 'AbCdEfGhIjKlMnOpQrStUvWxYz 1234567890 ~`!@#$%^&()_-+=|}{"\';><.,'
    #   expect(arm.valid?).to eq(true)
    # end

    it 'may contain "2 and"' do
      arm = build(:arm, protocol: @protocol)
      arm.name = 'Arm 2 and three'

      expect(arm.valid?). to eq(true)
    end

    it 'must not have the same name as another arm on its protocol' do
      arm1 = create(:arm, protocol: @protocol, name: 'arm')
      arm2 = build(:arm, protocol: @protocol, name: 'arm')

      expect(arm2.valid?).to eq(false)
    end
  end

  context 'Visit Count validations' do

  end

  context 'Subject count validations' do

  end
end