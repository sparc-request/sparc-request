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

RSpec.describe 'User manages associated surveys', js: true do
  let_there_be_lane
  fake_login_for_each_test

  before :each do
    @institution        = create(:institution)
    @provider           = create(:provider, parent_id: @institution.id)
    @survey             = create(:survey, active: true, type: 'SystemSurvey')
    create(:catalog_manager, organization_id: @institution.id, identity_id: Identity.where(ldap_uid: 'jug2').first.id)

    visit catalog_manager_catalog_index_path
    wait_for_javascript_to_finish
    find("#institution-#{@institution.id}").click
    wait_for_javascript_to_finish
    click_link @provider.name
    wait_for_javascript_to_finish

    click_link 'Associated Surveys'
    wait_for_javascript_to_finish
  end

  context ' and the organization does not have associated surveys' do
    it 'should add the associated survey for the organization' do
      bootstrap_select('.new_associated_survey', "Version #{@survey.version}")
      find("button.add-associated-survey").click
      wait_for_javascript_to_finish

      expect(AssociatedSurvey.where(associable_id: @provider.id).count).to eq(1)
      expect(page).to have_selector("#survey-row-#{@provider.associated_surveys.first.id}")
    end
  end

  context ' and the organization has associated survey' do
    before :each do
      @associated_survey  = create(:associated_survey, associable_id: @provider.id, survey_id: @survey.id, associable_type: 'Organization')
    end

    it 'should throw an error if the same associated survey is added again' do
      bootstrap_select('.new_associated_survey', "Version #{@survey.version}")
      find("button.add-associated-survey").click
      wait_for_javascript_to_finish

      expect(page).to have_content('The survey you are trying to add is already associated with this Organization')
    end
  end

end
