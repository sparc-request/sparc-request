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

RSpec.describe QuestionResponse, type: :model do
  it 'should have a valid factory' do
    expect(build(:question_response)).to be_valid
  end
  
  # Associations
  it { is_expected.to belong_to(:question) }
  it { is_expected.to belong_to(:response) }

  # Validations
  context 'question_type == phone' do
    it 'should return true if blank' do
      q   = create(:question, question_type: 'phone')
      qr  = build(:question_response, question: q, content: '')

      expect(qr).to be_valid
    end

    it 'should return false if invalid format' do
      q   = create(:question, question_type: 'phone')
      qr1 = build(:question_response, question: q, content: 'my phone number')
      qr2 = build(:question_response, question: q, content: '123-456-7890')
      qr3 = build(:question_response, question: q, content: '(123) 456-7890')
      qr4 = build(:question_response, question: q, content: '123 456 789o') 

      expect(qr1).to_not be_valid
      expect(qr2).to_not be_valid
      expect(qr3).to_not be_valid
      expect(qr4).to_not be_valid
    end
    
    it 'should return true if valid format' do
      q   = create(:question, question_type: 'phone')
      qr  = build(:question_response, question: q, content: '1234567890')

      expect(qr).to be_valid
    end
  end

  context 'question_type == email' do
    it 'should return true if blank' do
      q   = create(:question, question_type: 'email')
      qr  = build(:question_response, question: q, content: '')

      expect(qr).to be_valid
    end

    it 'should return false if invalid format' do
      q   = create(:question, question_type: 'email')
      qr1 = build(:question_response, question: q, content: 'email@email@co.us')
      qr2 = build(:question_response, question: q, content: 'emailemail.co.us')
      qr3 = build(:question_response, question: q, content: 'my email')

      expect(qr1).to_not be_valid
      expect(qr2).to_not be_valid
      expect(qr3).to_not be_valid
    end

    it 'should return true if valid format' do
      q   = create(:question, question_type: 'email')
      qr1 = build(:question_response, question: q, content: 'email@email.com')
      qr2 = build(:question_response, question: q, content: 'email_stuff@musc.edu')
      qr3 = build(:question_response, question: q, content: 'email@email.org.us')
      qr4 = build(:question_response, question: q, content: 'my-email@email.gov')

      expect(qr1).to be_valid
      expect(qr2).to be_valid
      expect(qr3).to be_valid
      expect(qr4).to be_valid
    end
  end

  context 'question_type == zipcode' do
    it 'should return true if blank' do
      q   = create(:question, question_type: 'zipcode')
      qr  = build(:question_response, question: q, content: '')

      expect(qr).to be_valid
    end

    it 'should return false if invalid format' do
      q   = create(:question, question_type: 'zipcode')
      qr1 = build(:question_response, question: q, content: 'zipcode')
      qr2 = build(:question_response, question: q, content: '1234')
      qr3 = build(:question_response, question: q, content: '123456789')
      qr4 = build(:question_response, question: q, content: '12345.6789') 

      expect(qr1).to_not be_valid
      expect(qr2).to_not be_valid
      expect(qr3).to_not be_valid
      expect(qr4).to_not be_valid
    end
    
    it 'should return true if valid format' do
      q   = create(:question, question_type: 'zipcode')
      qr1 = build(:question_response, question: q, content: '12345')
      qr2 = build(:question_response, question: q, content: '12345-6789')

      expect(qr1).to be_valid
      expect(qr2).to be_valid
    end
  end

  # Callbacks
  it { is_expected.to callback(:remove_unanswered).before(:save) }
end
