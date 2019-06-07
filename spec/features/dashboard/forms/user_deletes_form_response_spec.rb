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

RSpec.describe 'User deletes a form response', js: true do
  let_there_be_lane

  fake_login_for_each_test

  before :each do
    institution = create(:institution, name: "Institution")
    provider    = create(:provider, name: "Provider", parent: institution)
    program     = create(:program, name: "Program", parent: provider, process_ssrs: true)
    service     = create(:service, name: "Service", abbreviation: "Service", organization: program)
    @protocol   = create(:protocol_federally_funded, type: 'Study', primary_pi: jug2)
    @sr         = create(:service_request_without_validations, protocol: @protocol)
    ssr         = create(:sub_service_request_without_validations, protocol: @protocol, service_request: @sr, organization: program)
                  create(:line_item, service_request: @sr, sub_service_request: ssr, service: service)
                  create(:arm, protocol: @protocol, visit_count: 1)
    form        = create(:form, :with_question, surveyable: service, active: true)
    response    = create(:response, survey: form, respondable: ssr)
                  create(:question_response, response: response, question: form.questions.first, content: 'Respondability')
  end

  context 'and there are no other completed forms' do
    scenario 'and sees the forms panel disappear' do
      visit dashboard_protocol_path(@protocol)
      wait_for_javascript_to_finish

      expect(page).to have_selector('#forms-panel', visible: true)

      first('.delete-response').click
      wait_for_javascript_to_finish

      find('.sweet-alert.visible button.confirm').click
      wait_for_javascript_to_finish

      expect(page).to have_selector('#forms-panel', visible: false)
    end
  end

  context 'with no other forms to complete' do
    scenario 'and sees the forms column on the service requests table appear' do
      visit dashboard_protocol_path(@protocol)
      wait_for_javascript_to_finish

      first('.delete-response').click
      wait_for_javascript_to_finish

      find('.sweet-alert.visible button.confirm').click
      wait_for_javascript_to_finish

      expect(page).to have_content('Complete Form')
    end
  end

  scenario 'and sees the response was deleted' do
    visit dashboard_protocol_path(@protocol)
    wait_for_javascript_to_finish

    first('.delete-response').click
    wait_for_javascript_to_finish

    find('.sweet-alert.visible button.confirm').click
    wait_for_javascript_to_finish

    expect(Response.count).to eq(0)
  end
end
