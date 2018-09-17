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

RSpec.describe 'User previews a survey', js: true do
  let_there_be_lane
  fake_login_for_each_test

  stub_config("site_admins", ["jug2"])

  context 'surveys' do
    before :each do
      @survey = create(:system_survey)
      s1      = create(:section, survey: @survey)
      s2      = create(:section, survey: @survey)
      s3      = create(:section, survey: @survey)
      q1      = create(:question, section: s1, question_type: 'dropdown')
      q2      = create(:question, section: s1)
      q3      = create(:question, section: s2)
      o1      = create(:option, question: q1)
      o2      = create(:option, question: q1)

      visit surveyor_surveys_path
      wait_for_javascript_to_finish

      bootstrap_select '.survey-actions', /Preview/
      wait_for_javascript_to_finish
    end

    scenario 'and sees the preview modal' do
      expect(page).to have_selector('#preview-modal')
    end

    scenario 'and sees all proper content' do
      expect(all('.section').count).to eq(@survey.sections.count)
      expect(all('.question').count).to eq(@survey.questions.count)
      expect(all('.option').count).to eq(@survey.questions.map(&:options).flatten.count)
    end
  end

  context 'forms' do
    before :each do
      org = create(:institution)
      create(:super_user, organization: org, identity: jug2)
      @form = create(:form, surveyable: org)
      s1      = create(:section, survey: @form)
      s2      = create(:section, survey: @form)
      s3      = create(:section, survey: @form)
      q1      = create(:question, section: s1, question_type: 'dropdown')
      q2      = create(:question, section: s1)
      q3      = create(:question, section: s2)
      o1      = create(:option, question: q1)
      o2      = create(:option, question: q1)

      visit surveyor_surveys_path
      wait_for_javascript_to_finish

      bootstrap_select '.survey-actions', /Preview/
      wait_for_javascript_to_finish
    end

    scenario 'and sees the preview modal' do
      expect(page).to have_selector('#preview-modal')
    end

    scenario 'and sees all proper content' do
      expect(all('.section').count).to eq(@form.sections.count)
      expect(all('.question').count).to eq(@form.questions.count)
      expect(all('.option').count).to eq(@form.questions.map(&:options).flatten.count)
    end
  end
end
