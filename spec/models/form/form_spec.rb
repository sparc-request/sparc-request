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

RSpec.describe Form, type: :model do
  it 'should have a valid factory' do
    expect(build(:form)).to be_valid
  end

  # Inheritance
  it { expect(Form.ancestors.include?(Survey)).to eq(true) }

  # Validations
  context 'active scoping to access_code' do
    it 'should only allow 1 active form to each access code associated to a surveyable entity' do
      org = create(:organization)

      survey1 = create(:form, surveyable: org, access_code: 'some-form', active: true)

      expect(build(:form, surveyable: org, access_code: 'some-form', active: true)).to_not be_valid
    end

    it 'should allow multiple inactive forms with the same access code on the same surveyable entity' do
      org = create(:organization)

      survey1 = create(:form, surveyable: org, access_code: 'some-form', active: true)

      expect(build(:form, surveyable: org, access_code: 'some-form', active: false)).to be_valid
    end

    it 'should allow multiple active forms with the same active code for different organizations' do
      org1 = create(:organization)
      org2 = create(:organization)

      survey1 = create(:form, surveyable: org1, access_code: 'some-form', active: true)

      expect(build(:form, surveyable: org2, access_code: 'some-form', active: true)).to be_valid
    end
  end
end
