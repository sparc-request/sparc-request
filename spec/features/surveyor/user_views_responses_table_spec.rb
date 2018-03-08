# Copyright © 2011-2018 MUSC Foundation for Research Development
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

RSpec.describe 'User views the responses table', js: true do
  let_there_be_lane
  fake_login_for_each_test
  
  context 'completed responses' do
    before :each do
      @form = create(:form)
      @s1   = create(:section, survey: @form)
      @q1   = create(:question, section: @s1)
      @resp = create(:response, survey: @form)
      @qr1  = create(:question_response, response: @resp, question: @q1)
    end

    scenario 'user should see an active "View" button' do
      visit surveyor_responses_path
      wait_for_javascript_to_finish

      expect(page).to have_selector('.view-response:not(.disabled)')
    end

    scenario 'user should see an active "Edit" button' do
      visit surveyor_responses_path
      wait_for_javascript_to_finish

      expect(page).to have_selector('.edit-response:not(.disabled)')
    end
  end

  context 'incomplete responses' do
    before :each do
      @form = create(:form)
      @s1   = create(:section, survey: @form)
      @q1   = create(:question, section: @s1)
      @resp = create(:response, survey: @form)
    end

    scenario 'user should see a disabled "View" button' do
      visit surveyor_responses_path
      wait_for_javascript_to_finish

      expect(page).to have_selector('.view-response.disabled')
    end

    scenario 'user should see a disabled "Edit" button' do
      visit surveyor_responses_path
      wait_for_javascript_to_finish

      expect(page).to have_selector('.edit-response.disabled')
    end
  end
end
