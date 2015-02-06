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

require 'spec_helper'

describe "landing page", :js => true do
  let_there_be_lane
  let_there_be_j
  fake_login_for_each_test

  after :each do
    wait_for_javascript_to_finish
  end

  describe "notifications link" do
    it 'should work' do
      visit portal_root_path
      find(".notifications-link a.hyperlink").click
      wait_for_javascript_to_finish
      sleep 2
      find(".notifications_popup").should be_visible
    end
  end

  describe "with no requests" do
    it 'should be empty' do
      visit portal_root_path
      page.should_not have_css("div#protocol-accordion h3")
    end
  end

  describe "with requests" do
    build_service_request_with_project

    before :each do
      add_visits
      visit portal_root_path
    end

    it 'should have requests' do
      page.should have_css("div#protocol-accordion h3")
    end

    it 'should bring up the edit user box' do
      within(".Julia") do
        find("a.edit-associated-user-button").click
        wait_for_javascript_to_finish
      end
      page.should have_text("Edit an Authorized User")
    end

    it 'should allow user to delete users' do
      test_user = FactoryGirl.create(:identity, last_name:'Glenn2', first_name:'Julia2', ldap_uid:'jug3', institution:'medical_university_of_south_carolina', college:'college_of_medecine', department:'other', email:'glennj2@musc.edu', credentials:'BS,    MRA', catalog_overlord: true, password:'p4ssword', password_confirmation:'p4ssword', approved: true)
      project_role = FactoryGirl.create(:project_role, protocol_id: service_request.protocol.id, identity_id: test_user.id, project_rights: "approve", role: "co-investigator")
      visit portal_root_path

      find("tr.Julia2 .delete-associated-user-button").click
      page.driver.browser.switch_to.alert.accept
      page.should_not have_css("tr.Julia2")
    end

    it 'should not delete the user if only pi' do

      within(".Julia") do
        find("a.delete-associated-user-button").click
        page.driver.browser.switch_to.alert.accept # Accept Delete
      end
      page.should have_css('tr.Julia')
    end

    it 'should bring up the add user box' do
      find("div.associated-user-button").click
      find(".add-associated-user-dialog").should be_visible
    end

    it 'should allow user to edit the service request' do
      find("td.edit-td .edit_service_request").click
      page.should have_text("Editing ID: #{service_request.protocol_id}")
    end

    it 'should allow user to view the service request' do
      find(".view-sub-service-request-button").click
      within ".project_information" do
        find("td.protocol-id-td").should have_exact_text(service_request.protocol_id.to_s + '-' + sub_service_request.ssr_id)
      end
    end

    it 'should allow user to edit original service request' do
      find("td.edit-original-td a").click
      page.should have_text("Welcome to the SPARC Request Services Catalog")
      page.should_not have_text("Editing ID: #{service_request.protocol_id}")
    end

    it 'should allow user to add additional services to request' do
      find(".add-services-button").click
      page.should have_text("Welcome to the SPARC Request Services Catalog")
      page.should_not have_text("Editing ID: #{service_request.protocol_id}")
      page.should_not have_css("div#services div.line_item")
    end

    it 'should be able to search' do
      wait_for_javascript_to_finish
      find("h3#blue-provider-#{service_request.protocol_id} a").click
      wait_for_javascript_to_finish
      page.fill_in 'search_box', :with => "#{service_request.protocol_id}"
      wait_for_javascript_to_finish
      find("ul.ui-autocomplete li.ui-menu-item a.ui-corner-all").click
      find("div.protocol-information-#{service_request.protocol_id}").should be_visible
    end

     it "should click button in user portal" do 
      find('.portal_create_new_study').click
      wait_for_javascript_to_finish
      page.should have_content "Short Title"
    end
  end
end
