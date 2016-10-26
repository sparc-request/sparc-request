# Copyright © 2011-2016 MUSC Foundation for Research Development
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
    page
  end

  let!(:bob)                      { create(:identity) }

  context 'for an editable SSR' do
    context 'As an Authorized User with Edit Privileges' do
      let!(:protocol)             { create(:unarchived_study_without_validations, primary_pi: jug2) }
      let!(:service_request)      { create(:service_request_without_validations, protocol: protocol, status: 'draft') }
      let!(:organization)         { create(:organization,type: 'Institution', name: 'Megacorp', admin: bob, service_provider: bob) }
      let!(:sub_service_request)  { create(:sub_service_request, id: 9999, ssr_id: '1234', service_request: service_request, organization_id: organization.id, status: 'draft') }

      scenario 'and sees View and Edit' do
        page = go_to_show_protocol(protocol.id)

        expect(page).to have_selector('button', text: /\AView\z/)
        expect(page).to have_selector('button', text: /\AEdit\z/)
        expect(page).not_to have_selector('button', text: 'Admin Edit')
      end

      context 'for a locked SSR' do
        let!(:protocol)             { create(:unarchived_study_without_validations, primary_pi: jug2) }
        let!(:service_request)      { create(:service_request_without_validations, protocol: protocol, status: 'draft') }
        let!(:organization)         { create(:organization,type: 'Institution', name: 'Megacorp', admin: bob, service_provider: bob) }
        
        scenario 'and sees View but not Edit' do
          EDITABLE_STATUSES[organization.id] = ['draft']

          sub_service_request.update_attribute(:status, 'on_hold')

          page = go_to_show_protocol(protocol.id)

          expect(page).to have_selector('button', text: /\AView\z/)
          expect(page).not_to have_selector('button', text: /\AEdit\z/)
          expect(page).not_to have_selector('button', text: 'Admin Edit')
        end
      end
    end

    context 'As an Authorized User with View Privileges' do
      let!(:protocol)             { create(:unarchived_study_without_validations, primary_pi: bob) }
      let!(:service_request)      { create(:service_request_without_validations, protocol: protocol, status: 'draft') }
      let!(:organization)         { create(:organization,type: 'Institution', name: 'Megacorp', admin: bob, service_provider: bob) }
      let!(:sub_service_request)  { create(:sub_service_request, id: 9999, ssr_id: '1234', service_request: service_request, organization_id: organization.id, status: 'draft') }

      scenario 'and sees View' do
        create(:project_role, identity: jug2, protocol: protocol, project_rights: 'view', role: 'consultant')

        page = go_to_show_protocol(protocol.id)

        expect(page).to have_selector('button', text: /\AView\z/)
        expect(page).not_to have_selector('button', text: /\AEdit\z/)
        expect(page).not_to have_selector('button', text: 'Admin Edit')
      end
    end

    context 'As an admin' do
      let!(:protocol)             { create(:unarchived_study_without_validations, primary_pi: bob) }
      let!(:service_request)      { create(:service_request_without_validations, protocol: protocol, status: 'draft') }
      let!(:organization)         { create(:organization,type: 'Institution', name: 'Megacorp', admin: jug2, service_provider: jug2) }
      let!(:sub_service_request)  { create(:sub_service_request, id: 9999, ssr_id: '1234', service_request: service_request, organization_id: organization.id, status: 'draft') }

      scenario 'and sees View, and Admin Edit, but not Edit' do
        page = go_to_show_protocol(protocol.id)

        expect(page).to have_selector('button', text: /\AView\z/)
        expect(page).not_to have_selector('button', text: /\AEdit\z/)
        expect(page).to have_selector('button', text: 'Admin Edit')
      end
    end
  end
end
