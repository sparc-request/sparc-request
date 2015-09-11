# Copyright © 2011 MUSC Foundation for Research Development
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

RSpec.describe 'landing page', js: true do

  let_there_be_lane
  let_there_be_j
  fake_login_for_each_test

  let(:identity) { Identity.find_by_ldap_uid 'jug2' }

  describe "notifications link" do
    it 'should work' do
      visit portal_root_path
      find(".notifications-link a.hyperlink").click
      wait_for_javascript_to_finish
      wait_for_javascript_to_finish
      expect(find(".notifications_popup")).to be_visible
    end
  end

  describe "with no requests" do
    it 'should be empty' do
      visit portal_root_path
      expect(page).not_to have_css("div#protocol-accordion h3")
    end
  end

  describe "with requests" do
    build_service_request_with_project

    before :each do
      add_visits
      visit portal_root_path
    end

    it 'should have requests' do
      expect(page).to have_css("div#protocol-accordion h3")
    end

    it 'should bring up the edit user box' do
      test_user     = create(:identity, last_name:'Glenn2', first_name:'Julia2', ldap_uid:'jug3', institution:'medical_university_of_south_carolina', college:'college_of_medecine', department:'other', email:'glennj2@musc.edu', credentials:'BS,    MRA', catalog_overlord: true, password:'p4ssword', password_confirmation:'p4ssword', approved: true)
      project_role  = create(:project_role, protocol_id: service_request.protocol.id, identity_id: test_user.id, project_rights: "approve", role: "co-investigator")

      find("tr[data-user-id='#{test_user.id}'] .edit-associated-user-button").click

      expect(page).to have_text("Edit an Authorized User")
    end

    it 'should allow user to delete users' do
      test_user     = create(:identity, last_name:'Glenn2', first_name:'Julia2', ldap_uid:'jug3', institution:'medical_university_of_south_carolina', college:'college_of_medecine', department:'other', email:'glennj2@musc.edu', credentials:'BS,    MRA', catalog_overlord: true, password:'p4ssword', password_confirmation:'p4ssword', approved: true)
      project_role  = create(:project_role, protocol_id: service_request.protocol.id, identity_id: test_user.id, project_rights: "approve", role: "co-investigator")

      find("tr[data-user-id='#{test_user.id}'] .delete-associated-user-button").click
      wait_for_javascript_to_finish

      expect(page).not_to have_css("tr[data-user-id='#{test_user.id}']")
    end

    it 'should not delete the user if only pi' do
      find("tr[data-user-id='#{identity.id}'] .delete-associated-user-button").click

      expect(page).to have_css("tr[data-user-id='#{identity.id}']")
    end

    it 'should bring up the add user box' do
      find("div.associated-user-button").click
      expect(find(".add-associated-user-dialog")).to be_visible
    end

    it 'should allow user to edit the service request' do
      find("td.edit-td .edit_service_request").click
      expect(page).to have_text("Editing ID: #{service_request.protocol_id}")
    end

    it 'should allow user to view the service request' do
      find(".view-sub-service-request-button").click
      within ".project_information" do
        expect(find("td.protocol-id-td")).to have_exact_text(service_request.protocol_id.to_s + '-' + sub_service_request.ssr_id)
      end
    end

    it 'should allow user to view consolidated request' do
      find('.view-full-calendar-button').click
      wait_for_javascript_to_finish
      within ".project_information" do
        expect(find("td.protocol-id-td")).to have_exact_text(service_request.protocol_id.to_s)
      end
    end

    it 'should allow user to view printer friendly consolidated request' do
      find('.view-full-calendar-button').click
      wait_for_javascript_to_finish
      new_window = window_opened_by { click_button 'Print' }
      wait_for_javascript_to_finish
      within_window new_window do
        expect(find('td.protocol-id-td')).to have_exact_text(service_request.protocol_id.to_s)
        expect(current_path).to eq URI.parse("/portal/protocols/#{service_request.protocol_id}/view_full_calendar").path
      end
    end

    it 'should allow user to view printer-friendly service request' do
      find(".view-sub-service-request-button").click
      new_window = window_opened_by { click_button 'Print' }
      within_window new_window do
        find("td.protocol-id-td").should have_exact_text(service_request.protocol_id.to_s + '-' + sub_service_request.ssr_id)
        expect(current_path).to eq URI.parse("/portal/service_requests/#{service_request.protocol_id}?ssr_id=#{sub_service_request.ssr_id}").path
      end
    end

    it 'should allow user to edit original service request' do
      find("td.edit-original-td a").click
      expect(page).to have_text("Welcome to the SPARC Request Services Catalog")
      expect(page).not_to have_text("Editing ID: #{service_request.protocol_id}")
    end

    it 'should allow user to add additional services to request' do
      find(".add-services-button").click
      expect(page).to have_text("Welcome to the SPARC Request Services Catalog")
      expect(page).not_to have_text("Editing ID: #{service_request.protocol_id}")
      expect(page).not_to have_css("div#services div.line_item")
    end

    it 'should be able to search' do
      wait_for_javascript_to_finish
      find("h3#blue-provider-#{service_request.protocol_id} a").click
      wait_for_javascript_to_finish
      page.fill_in 'search_box', with: "#{service_request.protocol_id}"
      wait_for_javascript_to_finish
      find("ul.ui-autocomplete li.ui-menu-item a.ui-corner-all").click
      expect(find("div.protocol-information-#{service_request.protocol_id}")).to be_visible
    end

     it "should click button in user portal" do
      find('.portal_create_new_study').click
      wait_for_javascript_to_finish

      expect(page).to have_content "Short Title"
    end
  end
end
