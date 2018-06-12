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

RSpec.describe 'User previews an associated survey', js: true do
  let_there_be_lane
  fake_login_for_each_test

  let!(:institution)  { create(:institution) }
  let!(:provider)     { create(:provider, parent: institution) }
  let!(:cm)           { create(:catalog_manager, identity: jug2, organization: provider) }
  
  let!(:survey)       { create(:system_survey, active: true) }
  let!(:section)      { create(:section, survey: survey) }
  let!(:question)     { create(:question, section: section) }

  before :each do
    visit catalog_manager_root_path
    wait_for_javascript_to_finish
  end

  scenario 'and asses the survey preview' do
    click_link institution.name
    click_link provider.name
    find('.legend', text: 'Surveys').click
    select "Version #{survey.version}", from: 'new_associated_survey'
    find('.add_associated_survey').click
    wait_for_javascript_to_finish
    
    new_window = window_opened_by { first('.associated_survey_link').click }
    
    within_window new_window do
      expect(page).to have_selector('#survey-panel')
    end
  end
end
