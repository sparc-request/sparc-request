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
require 'timecop'

RSpec.describe 'User takes a survey', js: true do
  let_there_be_lane

  fake_login_for_each_test

  before :each do
    @survey   = create(:system_survey, :with_question, title: "My Survey", active: true)
    @section  = create(:section, survey: @survey)
    org       = create(:organization)
    @ssr      = create(:sub_service_request_without_validations, organization: org)
    @response = create(:response, survey: @survey, identity: jug2, respondable_type: 'SubServiceRequest', respondable_id: @ssr.id)
  end

  context 'and selects an option with a dependent question' do
    scenario 'and sees the dependent question' do
      @q_radio_button = create(:question, section: @section, question_type: 'radio_button', content: 'Radio Button Question')
      @opt1           = create(:option, question: @q_radio_button, content: "Option 1")
      @opt2           = create(:option, question: @q_radio_button, content: "Option 2")
      @q_dependent    = create(:question, section: @section, content: 'Dependent Question', depender: @opt1)

      visit edit_surveyor_response_path(@response)
      wait_for_javascript_to_finish

      first('input').click
      wait_for_javascript_to_finish

      expect(page).to have_content('Dependent Question')
    end
  end

  context 'and fills out the survey and submits' do
    scenario 'and is redirected to the completed screen' do
      visit edit_surveyor_response_path(@response)
      wait_for_javascript_to_finish

      click_button 'Submit'

      complete_page = surveyor_response_complete_path(Response.last)
      wait_for_page(complete_page)

      expect(current_path).to eq(complete_page)
    end
  end
end
