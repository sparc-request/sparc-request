# Copyright © 2011-2017 MUSC Foundation for Research Development~
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

RSpec.describe 'User should see error - no questions created', js: true do
  let_there_be_lane
  fake_login_for_each_test

  scenario 'successfully' do
    service = create(:service, :with_ctrc_organization)
    visit new_service_additional_details_questionnaire_path(service)

    click_button 'Create Questionnaire'

    expect(Questionnaire.count).to eq 0
    expect(page).to have_content(
      'At least one question must exist in order to create a form.')
  end

  scenario 'successfully - fills out name' do
    service = create(:service, :with_ctrc_organization)
    visit new_service_additional_details_questionnaire_path(service)

    fill_in 'questionnaire_name', with: 'New Questionnaire'
    click_button 'Create Questionnaire'

    expect(page).to have_content(
      'At least one question must exist in order to create a form.')
  end

  scenario 'successfully' do
    service = create(:service, :with_ctrc_organization)
    visit new_service_additional_details_questionnaire_path(service)
    fill_in 'questionnaire_name', with: 'New Questionnaire'
    fill_in 'questionnaire_items_attributes_0_content', with: 'What is your favorite color?'
    select 'Radio Button', from: 'questionnaire_items_attributes_0_item_type'
    fill_in 'questionnaire_items_attributes_0_item_options_attributes_0_content', with: 'Green'
    click_link 'Add another Option'
    fill_in 'questionnaire_items_attributes_0_item_options_attributes_1_content', with: 'Red'

    check 'questionnaire_items_attributes_0_required'

    click_button 'Create Questionnaire'

    expect(current_path).to eq service_additional_details_questionnaires_path(service)
    expect(Questionnaire.count).to eq 1
    expect(page).not_to have_content(
      'At least one question must exist in order to create a form.'
    )
  end
end

