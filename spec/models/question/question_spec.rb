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

RSpec.describe Question, type: :model do
  it 'should have a valid factory' do
    expect(build(:question)).to be_valid
  end
  
  # Associatins
  it { is_expected.to belong_to(:section) }
  it { is_expected.to belong_to(:depender).class_name('Option') }

  it { is_expected.to have_many(:options).dependent(:destroy) }
  it { is_expected.to have_many(:question_responses).dependent(:destroy) }
  it { is_expected.to have_many(:dependents).through(:options) }

  # Validations
  it { is_expected.to validate_presence_of(:content) }
  it { is_expected.to validate_presence_of(:question_type) }

  # Other
  it { is_expected.to accept_nested_attributes_for(:options) }

  it { is_expected.to delegate_method(:survey).to(:section) }

  # Callbacks
  describe 'update_options_based_on_question_type' do
    it 'should be called on update' do
      @question = create(:question, question_type: 'text')
      expect(@question).to receive(:update_options_based_on_question_type)
      @question.update_attribute(:question_type, 'email')
    end

    it 'should destroy options when if not a type with options' do
      @question = create(:question, question_type: 'likert', option_count: 2)
      expect(@question.options.count).to eq(2)
      @question.update_attribute(:question_type, 'text')
      expect(@question.options.count).to eq(0)
    end

    it 'should create yes/no options' do
      @question = create(:question, question_type: 'text')
      expect(@question.options.count).to eq(0)
      @question.update_attribute(:question_type, 'yes_no')
      expect(@question.options.count).to eq(2)
    end
  end
end
