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

RSpec.describe Survey, type: :model do
  it 'should have a valid factory' do
    expect(build(:survey)).to be_valid
  end
  
  # Associations
  it { is_expected.to have_many(:responses).dependent(:destroy) }
  it { is_expected.to have_many(:sections).dependent(:destroy) }
  it { is_expected.to have_many(:associated_surveys).dependent(:destroy) }
  it { is_expected.to have_many(:questions).through(:sections) }
  it { is_expected.to belong_to(:surveyable) }

  # Validations
  it { is_expected.to validate_presence_of(:title) }
  it { is_expected.to validate_presence_of(:access_code) }
  it { is_expected.to validate_presence_of(:version) }

  it { is_expected.to validate_numericality_of(:version).only_integer }
  it { is_expected.to validate_numericality_of(:version).is_greater_than(0) }

  it { expect(build(:survey)).to validate_uniqueness_of(:version).scoped_to([:access_code, :type]) }

  # Other
  it { is_expected.to accept_nested_attributes_for(:sections) }
end
