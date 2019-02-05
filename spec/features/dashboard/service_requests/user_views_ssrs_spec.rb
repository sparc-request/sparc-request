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

RSpec.describe "User views SSR table", js: true do
  let_there_be_lane
  fake_login_for_each_test

  def go_to_show_protocol(protocol_id)
    page = Dashboard::Protocols::ShowPage.new
    page.load(id: protocol_id)
    wait_for_javascript_to_finish
    page
  end

  let!(:bob)                      { create(:identity) }

  context 'for an editable SSR' do
    context 'As an Authorized User with Edit Privileges' do
      let!(:protocol)             { create(:unarchived_study_without_validations, primary_pi: jug2) }
      let!(:service_request)      { create(:service_request_without_validations, protocol: protocol, status: 'draft') }
      let!(:organization)         { create(:organization,type: 'Institution', name: 'Megacorp', admin: bob, service_provider: bob) }
      let!(:sub_service_request)  { create(:sub_service_request, id: 9999, ssr_id: '1234', service_request: service_request, organization_id: organization.id, status: 'draft', protocol: protocol) }

      scenario 'and sees View' do
        page = go_to_show_protocol(protocol.id)
        expect(page).to have_selector('button', text: /\AView\z/)
        expect(page).not_to have_selector('a', text: 'Admin Edit')
      end
    end

    context 'As an Authorized User with View Privileges' do
      let!(:protocol)             { create(:unarchived_study_without_validations, primary_pi: bob) }
      let!(:service_request)      { create(:service_request_without_validations, protocol: protocol, status: 'draft') }
      let!(:organization)         { create(:organization,type: 'Institution', name: 'Megacorp', admin: bob, service_provider: bob) }
      let!(:sub_service_request)  { create(:sub_service_request, id: 9999, ssr_id: '1234', service_request: service_request, organization_id: organization.id, status: 'draft', protocol: protocol) }

      scenario 'and sees View' do
        create(:project_role, identity: jug2, protocol: protocol, project_rights: 'view', role: 'consultant')

        page = go_to_show_protocol(protocol.id)

        expect(page).to have_selector('button', text: /\AView\z/)
        expect(page).not_to have_selector('a', text: 'Admin Edit')
      end
    end

    context 'As an admin' do
      let!(:protocol)             { create(:unarchived_study_without_validations, primary_pi: bob) }
      let!(:service_request)      { create(:service_request_without_validations, protocol: protocol, status: 'draft') }
      let!(:organization)         { create(:organization,type: 'Institution', name: 'Megacorp', admin: jug2, service_provider: jug2) }
      let!(:sub_service_request)  { create(:sub_service_request, id: 9999, ssr_id: '1234', service_request: service_request, organization_id: organization.id, status: 'draft', protocol: protocol) }

      scenario 'and sees View, and Admin Edit' do
        page = go_to_show_protocol(protocol.id)

        expect(page).to have_selector('button', text: /\AView\z/)
        expect(page).to have_selector('a', text: 'Admin Edit')
      end
    end
  end

  context 'for an SSR with forms to complete' do
    let!(:organization)         { create(:organization) }
    let!(:service)              { create(:service, organization: organization) }
    let!(:protocol)             { create(:protocol_federally_funded, primary_pi: jug2, type: 'Study') }
    let!(:service_request)      { create(:service_request_without_validations, protocol: protocol) }
    let!(:sub_service_request)  { create(:sub_service_request, service_request: service_request, organization: organization, status: 'draft', protocol: protocol) }
    let!(:line_item)            { create(:line_item, service_request: service_request, sub_service_request: sub_service_request, service: service) }
    let!(:form)                 { create(:form, :with_question, surveyable: service, active: true) }

    scenario 'and sees the complete form dropdown' do
      page = go_to_show_protocol(protocol.id)

      expect(page).to have_content('Complete Form')
      expect(page).to have_selector('.complete-forms .badge', text: /\A1\z/)
    end
  end

  context 'for a ssr without forms to complete' do
    let!(:organization)         { create(:organization) }
    let!(:service)              { create(:service, organization: organization) }
    let!(:protocol)             { create(:protocol_federally_funded, primary_pi: jug2, type: 'Study') }
    let!(:service_request)      { create(:service_request_without_validations, protocol: protocol) }
    let!(:sub_service_request)  { create(:sub_service_request, service_request: service_request, organization: organization, status: 'draft', protocol: protocol) }
    let!(:line_item)            { create(:line_item, service_request: service_request, sub_service_request: sub_service_request, service: service) }

    scenario 'and does not see the complete form dropdown' do
      page = go_to_show_protocol(protocol.id)

      expect(page).to have_no_selector('.complete-forms button .filter-option', text: /\AComplete Form\z/)
      expect(page).to have_no_selector('.complete-forms button .filter-option .badge', text: /\A1\z/)
    end
  end
end
