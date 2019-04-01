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

RSpec.describe 'User deletes a survey', js: true do
  let_there_be_lane
  fake_login_for_each_test

  stub_config("site_admins", ["jug2"])
  
  context 'surveys' do
    before :each do
      create(:system_survey)

      visit surveyor_surveys_path
      wait_for_javascript_to_finish
    end

    scenario 'and sees the survey is deleted' do
      bootstrap_select '.survey-actions', /Delete/
      wait_for_javascript_to_finish

      find('.sweet-alert.visible button.confirm').click
      wait_for_javascript_to_finish

      visit surveyor_surveys_path
      wait_for_javascript_to_finish

      expect(page).to have_selector('.survey-table td', text: 'No matching records found')
      expect(SystemSurvey.count).to eq(0)
    end
  end

  context 'forms' do
    before :each do
      org = create(:institution)
      create(:super_user, organization: org, identity: jug2)
      create(:form, surveyable: org)

      visit surveyor_surveys_path
      wait_for_javascript_to_finish
    end

    scenario 'and sees the form is deleted' do
      bootstrap_select '.survey-actions', /Delete/
      wait_for_javascript_to_finish

      find('.sweet-alert.visible button.confirm').click
      wait_for_javascript_to_finish

      visit surveyor_surveys_path
      wait_for_javascript_to_finish

      expect(page).to have_selector('.form-table td', text: 'No matching records found')
      expect(Form.count).to eq(0)
    end
  end
end
