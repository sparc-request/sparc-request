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

RSpec.describe 'User filters responses', js: true do
  let_there_be_lane
  fake_login_for_each_test

  stub_config('site_admins', ['jug2'])

  let!(:organization)     { create(:organization) }
  let!(:super_user)       { create(:super_user, identity: jug2, organization: organization) }
  let!(:form)             { create(:form, title: 'Formal Form', surveyable: organization) }
  let!(:survey)           { create(:system_survey, title: 'Serviceable Survey') }
  let!(:form_response)    { create(:response, survey: form) }
  let!(:survey_response)  { create(:response, survey: survey) }

  before :each do
    visit surveyor_responses_path
    wait_for_javascript_to_finish
  end

  describe 'type filter' do
    context 'User filters Forms' do
      scenario 'and sees only Forms' do
        bootstrap_select '#filterrific_with_type', 'Form'
        click_button 'Filter'
        wait_for_javascript_to_finish

        expect(page).to have_content(form.title)
        expect(page).to_not have_content(survey.title)
      end
    end

    context 'User filters Surveys' do
      scenario 'and sees only Surveys' do
        bootstrap_select '#filterrific_with_type', 'Survey'
        click_button 'Filter'
        wait_for_javascript_to_finish

        expect(page).to have_content(survey.title)
        expect(page).to_not have_content(form.title)
      end
    end
  end
end
