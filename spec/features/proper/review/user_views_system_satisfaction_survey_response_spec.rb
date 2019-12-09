# Copyright © 2011-2019 MUSC Foundation for Research Development~
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

RSpec.describe 'User views a System Satisfaction Survey response', js: true do
  let_there_be_lane
  fake_login_for_each_test

  before :each do
    @survey   = create(:system_survey, title: 'System Satisfaction Survey', access_code: 'system-satisfaction-survey')
    @section  = create(:section, survey: @survey, title: 'System Satisfaction')
    @question = create(:question, section: @section, content: '1) How satisfied are you with using SPARCRequest today?', question_type: 'likert')
    @opt_bad  = create(:option, question: @question, content: 'It was awful')
    @opt_good = create(:option, question: @question, content: 'It was great')

    @response = create(:response, survey: @survey, identity: jug2, respondable: create(:service_request_without_validations))
                create(:question_response, question: @question, response: @response, content: 'It was great')
  end

  it 'should show the response' do
    visit surveyor_response_path(@response)
    wait_for_javascript_to_finish

    expect(page).to have_content('System Satisfaction Survey')
    expect(page).to have_selector('.question', count: 1)
    expect(page).to have_selector('.likert-group', count: 1)
    expect(page).to have_selector('.likert input[checked="checked"]', count: 1)
    expect(page).to have_selector('.likert input[disabled="disabled"]', count: 2)
  end
end
