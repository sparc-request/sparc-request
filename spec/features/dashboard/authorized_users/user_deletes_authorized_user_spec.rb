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

RSpec.feature 'User wants to delete an authorized user', js: true do
  let_there_be_lane(catalog_overlord: false)
  fake_login_for_each_test

  let!(:other_user) { create(:identity, last_name: "Doe", first_name: "Jane", ldap_uid: "janed", email: "janed@musc.edu", password: "p4ssword", password_confirmation: "p4ssword", approved: true) }
  let!(:org)        { create(:organization, name: "Program", process_ssrs: true, pricing_setup_count: 1) }

  context 'user deletes a user' do
    before :each do
      @protocol = create(:study_federally_funded, primary_pi: jug2)
                  create(:service_request_without_validations, status: 'draft', protocol: @protocol)
                  create(:project_role, protocol: @protocol, identity: other_user, role: 'consultant')

      visit dashboard_protocol_path(@protocol)
      wait_for_javascript_to_finish
    end

    it 'should delete the user' do
      first('#authorizedUsers button[name="refresh"]').click
      wait_for_javascript_to_finish

      first('.delete-authorized-user:not(.disabled)').click
      confirm_swal
      wait_for_javascript_to_finish

      expect(@protocol.project_roles.count).to eq(1)
      expect(page).to have_no_content(other_user.full_name)
    end
  end

  context 'admin user deletes themself' do
    before :each do
      @protocol       = create(:study_federally_funded, primary_pi: other_user)
      sr              = create(:service_request_without_validations, status: 'draft', protocol: @protocol)
      ssr             = create(:sub_service_request_without_validations, service_request: sr, organization: org, status: 'draft', protocol: @protocol)
                        create(:project_role, :approve, protocol: @protocol, identity: jug2, role: 'consultant')
                        create(:super_user, organization: org, identity: jug2)

      @document = create(:document, protocol: @protocol)

      visit dashboard_protocol_path(@protocol)
      wait_for_javascript_to_finish
    end

    it 'should delete the user and refresh page contents to reflect their updated rights' do
      first('#authorizedUsers button[name="refresh"]').click
      wait_for_javascript_to_finish

      all('.delete-authorized-user:not(.disabled)').last.click
      confirm_swal
      wait_for_javascript_to_finish

      expect(@protocol.project_roles.count).to eq(1)
      expect(page).to have_no_content(jug2.full_name)
      expect(page).to have_no_content(I18n.t('dashboard.service_requests.modify_request'))
      expect(page).to have_no_selector('a', text: @document.document_file_name)
    end
  end

  context 'non-admin user deletes themself' do
    before :each do
      @protocol = create(:study_federally_funded, primary_pi: other_user)
                  create(:service_request_without_validations, status: 'draft', protocol: @protocol)
                  create(:project_role, :approve, protocol: @protocol, identity: jug2, role: 'consultant')

      visit dashboard_protocol_path(@protocol)
      wait_for_javascript_to_finish
    end

    it 'should redirect to the dashboard landing page' do
      first('#authorizedUsers button[name="refresh"]').click
      wait_for_javascript_to_finish

      all('.delete-authorized-user:not(.disabled)').last.click
      confirm_swal
      wait_for_javascript_to_finish

      expect(@protocol.project_roles.count).to eq(1)
      expect(page).to have_current_path(dashboard_root_path)
    end
  end
end
