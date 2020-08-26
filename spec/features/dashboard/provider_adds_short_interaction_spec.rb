# Copyright © 2011-2020 MUSC Foundation for Research Development~
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

RSpec.describe 'Service Provider clicks Short Interaction', js: true do
  let_there_be_lane
  fake_login_for_each_test

  stub_config('use_short_interaction', true)

  before :each do
    institution       = create(:institution, name: "Institution")
    provider          = create(:provider, name: "Provider", parent: institution)
                        create(:service_provider, identity_id: jug2.id, organization_id: provider.id)
    other_institution = ProfessionalOrganization.create(name: "Other Institution", org_type: "institution")

    visit dashboard_root_path
    wait_for_javascript_to_finish
  end

  it 'should submit a short interaction' do
    click_link I18n.t('layout.dashboard.navigation.short_interaction')
    wait_for_javascript_to_finish

    fill_in 'short_interaction_duration_in_minutes', with: '10'
    fill_in 'short_interaction_name', with: 'Tester'
    fill_in 'short_interaction_email', with: 'test@abc.com'
    fill_in 'short_interaction_note', with: 'testing'

    bootstrap_select '#short_interaction_institution', 'Other Institution'
    bootstrap_select '#short_interaction_subject', 'General Question'
    bootstrap_select '#short_interaction_interaction_type', 'Email'

    click_button I18n.t('actions.submit')
    wait_for_javascript_to_finish

    expect(jug2.short_interactions.count).to eq(1)
  end
end
