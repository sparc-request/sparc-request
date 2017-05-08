# Copyright © 2011-2016 MUSC Foundation for Research Development~
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

require "rails_helper"

RSpec.describe "User filters using Search functionality", js: :true do

  let_there_be_lane
  fake_login_for_each_test

  let!(:other_user) { create(:identity, first_name: 'John', last_name: 'Doe') }

  context "Short/Long Title search" do
    before :each do
      organization1 = create(:organization)
      organization2 = create(:organization)
      organization3 = create(:organization)
      
      @protocol1 = create(:study_without_validations, primary_pi: jug2, title: "title%", short_title: "Protocol1")
      @protocol2 = create(:study_without_validations, primary_pi: jug2, title: "xTitle", short_title: "Protocol2")
      @protocol3 = create(:study_without_validations, primary_pi: jug2, title: "a%a", short_title: "Protocol3")

      service_request1 = create(:service_request_without_validations, protocol: @protocol1)
      service_request2 = create(:service_request_without_validations, protocol: @protocol2)
      service_request3 = create(:service_request_without_validations, protocol: @protocol3)

      visit dashboard_protocols_path
      wait_for_javascript_to_finish

      expect(page).to have_selector(".protocols_index_row", count: 3)
    end

    it "should match against title case insensitively (lowercase)" do
      bootstrap_select '#filterrific_search_query_search_drop', 'Short/Long Title'
      fill_in 'filterrific_search_query_search_text', with: 'title'
      find('#apply-filter-button').click
      wait_for_javascript_to_finish

      expect(page).to have_selector(".protocols_index_row", count: 2)
      expect(page).to have_content(@protocol1.short_title)
      expect(page).to have_content(@protocol2.short_title)
      expect(page).to_not have_content(@protocol3.short_title)
    end

    it "should match against whole short title case insensitively (uppercase)" do
      bootstrap_select '#filterrific_search_query_search_drop', 'Short/Long Title'
      fill_in 'filterrific_search_query_search_text', with: 'Protocol1'
      find('#apply-filter-button').click
      wait_for_javascript_to_finish

      expect(page).to have_selector(".protocols_index_row", count: 1)
      expect(page).to have_content(@protocol1.short_title)
      expect(page).to_not have_content(@protocol2.short_title)
      expect(page).to_not have_content(@protocol3.short_title)
    end

    it "should match against partial short title case insensitively (uppercase)" do
      bootstrap_select '#filterrific_search_query_search_drop', 'Short/Long Title'
      fill_in 'filterrific_search_query_search_text', with: 'Protocol'
      find('#apply-filter-button').click
      wait_for_javascript_to_finish

      expect(page).to have_selector(".protocols_index_row", count: 3)
      expect(page).to have_content(@protocol1.short_title)
      expect(page).to have_content(@protocol2.short_title)
      expect(page).to have_content(@protocol3.short_title)
    end

    it "should match against displaying special characters" do
      bootstrap_select '#filterrific_search_query_search_drop', 'Short/Long Title'
      fill_in 'filterrific_search_query_search_text', with: '%'
      find('#apply-filter-button').click
      wait_for_javascript_to_finish

      expect(page).to have_selector(".protocols_index_row", count: 2)
      expect(page).to have_content(@protocol1.short_title)
      expect(page).to_not have_content(@protocol2.short_title)
      expect(page).to have_content(@protocol3.short_title)
    end
  end



  context "Protocol ID search" do
    before :each do
      organization1 = create(:organization)
      organization2 = create(:organization)
      organization3 = create(:organization)
      
      @protocol1 = create(:study_without_validations, primary_pi: jug2, title: "title%", short_title: "Protocol1")
      @protocol2 = create(:study_without_validations, primary_pi: jug2, title: "xTitle", short_title: "Protocol2")
      @protocol3 = create(:study_without_validations, primary_pi: jug2, title: "a%a", short_title: "Protocol3")

      service_request1 = create(:service_request_without_validations, protocol: @protocol1)
      service_request2 = create(:service_request_without_validations, protocol: @protocol2)
      service_request3 = create(:service_request_without_validations, protocol: @protocol3)

      visit dashboard_protocols_path
      wait_for_javascript_to_finish

      expect(page).to have_selector(".protocols_index_row", count: 3)
    end

    it "should match against id" do
      bootstrap_select '#filterrific_search_query_search_drop', 'Protocol ID'
      fill_in 'filterrific_search_query_search_text', with: @protocol1.id.to_s
      find('#apply-filter-button').click
      wait_for_javascript_to_finish

      expect(page).to have_selector(".protocols_index_row", count: 1)
      expect(page).to have_content(@protocol1.short_title)
      expect(page).to_not have_content(@protocol2.short_title)
      expect(page).to_not have_content(@protocol3.short_title)
    end
  end



  context 'Authorized User Search' do
    before :each do
      organization1 = create(:organization)
      organization2 = create(:organization)
      organization3 = create(:organization)
      
      @protocol1 = create(:study_without_validations, primary_pi: jug2, title: "title%", short_title: "Protocol1")
      @protocol2 = create(:study_without_validations, primary_pi: jug2, title: "xTitle", short_title: "Protocol2")
      @protocol3 = create(:study_without_validations, primary_pi: jug2, title: "a%a", short_title: "Protocol3")

      create(:project_role, protocol: @protocol3, identity: other_user, project_rights: 'view', role: 'consultant') 

      service_request1 = create(:service_request_without_validations, protocol: @protocol1)
      service_request2 = create(:service_request_without_validations, protocol: @protocol2)
      service_request3 = create(:service_request_without_validations, protocol: @protocol3)

      visit dashboard_protocols_path
      wait_for_javascript_to_finish

      expect(page).to have_selector(".protocols_index_row", count: 3)
    end

    it "should match against associated users first name case insensitively (lowercase)" do
      bootstrap_select '#filterrific_search_query_search_drop', 'Authorized User'
      fill_in 'filterrific_search_query_search_text', with: other_user.first_name.downcase
      find('#apply-filter-button').click
      wait_for_javascript_to_finish
      
      expect(page).to have_selector(".protocols_index_row", count: 1)
      expect(page).to_not have_content(@protocol1.short_title)
      expect(page).to_not have_content(@protocol2.short_title)
      expect(page).to have_content(@protocol3.short_title)
    end

    it "should match against associated users last name case insensitively (uppercase)" do
      bootstrap_select '#filterrific_search_query_search_drop', 'Authorized User'
      fill_in 'filterrific_search_query_search_text', with: 'Doe'
      find('#apply-filter-button').click
      wait_for_javascript_to_finish

      expect(page).to have_selector(".protocols_index_row", count: 1)
      expect(page).to_not have_content(@protocol1.short_title)
      expect(page).to_not have_content(@protocol2.short_title)
      expect(page).to have_content(@protocol3.short_title)
    end

    it "should not have any matches" do
      bootstrap_select '#filterrific_search_query_search_drop', 'Authorized User'
      fill_in 'filterrific_search_query_search_text', with: 'James Dowe'
      find('#apply-filter-button').click
      wait_for_javascript_to_finish

      expect(page).to have_selector(".protocols_index_row", count: 0)
      expect(page).to_not have_content(@protocol1.short_title)
      expect(page).to_not have_content(@protocol2.short_title)
      expect(page).to_not have_content(@protocol3.short_title)
    end
  end



  context 'PI Search' do
    before :each do
      organization1 = create(:organization)
      organization2 = create(:organization)
      organization3 = create(:organization)
      
      @protocol1 = create(:study_without_validations, primary_pi: jug2, title: "title%", short_title: "Protocol1")
      @protocol2 = create(:study_without_validations, primary_pi: jug2, title: "xTitle", short_title: "Protocol2")
      @protocol3 = create(:study_without_validations, primary_pi: jug2, title: "a%a", short_title: "Protocol3")

      service_request1 = create(:service_request_without_validations, protocol: @protocol1)
      service_request2 = create(:service_request_without_validations, protocol: @protocol2)
      service_request3 = create(:service_request_without_validations, protocol: @protocol3)

      visit dashboard_protocols_path
      wait_for_javascript_to_finish

      expect(page).to have_selector(".protocols_index_row", count: 3)
    end

    it "should match against pi first name case insensitively (lowercase)" do
      bootstrap_select '#filterrific_search_query_search_drop', 'PI'
      fill_in 'filterrific_search_query_search_text', with: @protocol3.principal_investigators.first.first_name.downcase
      find('#apply-filter-button').click
      wait_for_javascript_to_finish

      expect(page).to have_selector(".protocols_index_row", count: 1)
      expect(page).to_not have_content(@protocol1.short_title)
      expect(page).to_not have_content(@protocol2.short_title)
      expect(page).to have_content(@protocol3.short_title)
    end

    it "should match against pi last name case insensitively (uppercase)" do
      visit_protocols_index_page
      wait_for_javascript_to_finish

      expect(@page.search_results).to have_protocols(count: 3)

      @page.filter_protocols.select_search(@page, "PI", @protocol3.principal_investigators.first.last_name)
      @page.filter_protocols.apply_filter_button.click()
      wait_for_javascript_to_finish

      expect(@page.search_results).to have_no_protocols(text: "Protocol1")
      expect(@page.search_results).to have_no_protocols(text: "Protocol2")
      expect(@page.search_results).to have_protocols(text: "Protocol3")
    end

    it "should not have any matches" do
      visit_protocols_index_page
      wait_for_javascript_to_finish

      expect(@page.search_results).to have_protocols(count: 3)

      @page.filter_protocols.select_search(@page, "PI", "Johnbob")
      @page.filter_protocols.apply_filter_button.click()
      wait_for_javascript_to_finish

      expect(@page.search_results).to have_no_protocols(text: "Protocol1")
      expect(@page.search_results).to have_no_protocols(text: "Protocol2")
      expect(@page.search_results).to have_no_protocols(text: "Protocol3")
    end
  end



  context "RMID search" do
    before :each do
      organization1 = create(:organization)
      organization2 = create(:organization)
      organization3 = create(:organization)
      create(:service_provider, organization: organization1, identity: user)
      create(:service_provider, organization: organization2, identity: user)
      create(:service_provider, organization: organization3, identity: user)

      @protocol1 = create_protocol(archived: false, short_title: "Protocol1")
      create(:project_role, identity: user, role: "very-important", project_rights: "to-party", protocol: @protocol1)

      @protocol2 = create_protocol(archived: false, short_title: "Protocol2")
      create(:project_role, identity: user, role: "very-important", project_rights: "to-party", protocol: @protocol2)

      @protocol3 = create_protocol(archived: false, short_title: "Protocol3", research_master_id: 999999)
      create(:project_role, identity: user, role: "very-important", project_rights: "to-party", protocol: @protocol3)

      service_request1 = create(:service_request_without_validations, protocol: @protocol1)
                         create(:sub_service_request, service_request: service_request1, organization: organization1, status: 'draft', protocol_id: @protocol1.id)

      service_request2 = create(:service_request_without_validations, protocol: @protocol2)
                         create(:sub_service_request, service_request: service_request2, organization: organization2, status: 'draft', protocol_id: @protocol2.id)

      service_request3 = create(:service_request_without_validations, protocol: @protocol3)
                         create(:sub_service_request, service_request: service_request3, organization: organization3, status: 'draft', protocol_id: @protocol3.id)
    end

    it "should match against RMID" do
      visit_protocols_index_page
      wait_for_javascript_to_finish

      expect(@page.search_results).to have_protocols(count: 3)

      @page.filter_protocols.select_search(@page, "RMID", @protocol3.research_master_id)
      @page.filter_protocols.apply_filter_button.click()
      wait_for_javascript_to_finish

      expect(@page.search_results).to have_no_protocols(text: "Protocol1")
      expect(@page.search_results).to have_no_protocols(text: "Protocol2")
      expect(@page.search_results).to have_protocols(text: "Protocol3")
    end
  end



  context "HR# search" do
    before :each do
      organization1 = create(:organization)
      organization2 = create(:organization)
      organization3 = create(:organization)
      create(:service_provider, organization: organization1, identity: user)
      create(:service_provider, organization: organization2, identity: user)
      create(:service_provider, organization: organization3, identity: user)

      @protocol1 = create_protocol(archived: false, short_title: "Protocol1", study: true)
      create(:project_role, identity: user, role: "very-important", project_rights: "to-party", protocol: @protocol1)

      @protocol2 = create_protocol(archived: false, short_title: "Protocol2", study: true)
      create(:project_role, identity: user, role: "very-important", project_rights: "to-party", protocol: @protocol2)

      @protocol3 = create_protocol(archived: false, short_title: "Protocol3", study: true)
      create(:project_role, identity: user, role: "very-important", project_rights: "to-party", protocol: @protocol3)

      service_request1 = create(:service_request_without_validations, protocol: @protocol1)
                         create(:sub_service_request, service_request: service_request1, organization: organization1, status: 'draft', protocol_id: @protocol1.id)

      service_request2 = create(:service_request_without_validations, protocol: @protocol2)
                         create(:sub_service_request, service_request: service_request2, organization: organization2, status: 'draft', protocol_id: @protocol2.id)

      service_request3 = create(:service_request_without_validations, protocol: @protocol3)
                         create(:sub_service_request, service_request: service_request3, organization: organization3, status: 'draft', protocol_id: @protocol3.id)
    end

    it "should match against whole HR#" do
      visit_protocols_index_page
      wait_for_javascript_to_finish

      expect(@page.search_results).to have_protocols(count: 3)

      @page.filter_protocols.select_search(@page, "HR#", @protocol3.human_subjects_info.hr_number)
      @page.filter_protocols.apply_filter_button.click()
      wait_for_javascript_to_finish

      expect(@page.search_results).to have_no_protocols(text: "Protocol1")
      expect(@page.search_results).to have_no_protocols(text: "Protocol2")
      expect(@page.search_results).to have_protocols(text: "Protocol3")
    end

    it "should match against partial HR#" do
      visit_protocols_index_page
      wait_for_javascript_to_finish

      expect(@page.search_results).to have_protocols(count: 3)

      @page.filter_protocols.select_search(@page, "HR#", @protocol3.human_subjects_info.hr_number.split(//, 2).last)
      @page.filter_protocols.apply_filter_button.click()
      wait_for_javascript_to_finish

      expect(@page.search_results).to have_no_protocols(text: "Protocol1")
      expect(@page.search_results).to have_no_protocols(text: "Protocol2")
      expect(@page.search_results).to have_protocols(text: "Protocol3")
    end

    it "should not have any HR# matches" do
      visit_protocols_index_page
      wait_for_javascript_to_finish

      expect(@page.search_results).to have_protocols(count: 3)

      @page.filter_protocols.select_search(@page, "HR#", "1111111")
      @page.filter_protocols.apply_filter_button.click()
      wait_for_javascript_to_finish

      expect(@page.search_results).to have_no_protocols(text: "Protocol1")
      expect(@page.search_results).to have_no_protocols(text: "Protocol2")
      expect(@page.search_results).to have_no_protocols(text: "Protocol3")
    end
  end



  context "PRO# search" do
    before :each do
      organization1 = create(:organization)
      organization2 = create(:organization)
      organization3 = create(:organization)
      create(:service_provider, organization: organization1, identity: user)
      create(:service_provider, organization: organization2, identity: user)
      create(:service_provider, organization: organization3, identity: user)

      @protocol1 = create_protocol(archived: false, short_title: "Protocol1", study: true)
      create(:project_role, identity: user, role: "very-important", project_rights: "to-party", protocol: @protocol1)

      @protocol2 = create_protocol(archived: false, short_title: "Protocol2", study: true)
      create(:project_role, identity: user, role: "very-important", project_rights: "to-party", protocol: @protocol2)

      @protocol3 = create_protocol(archived: false, short_title: "Protocol3", study: true)
      create(:project_role, identity: user, role: "very-important", project_rights: "to-party", protocol: @protocol3)

      service_request1 = create(:service_request_without_validations, protocol: @protocol1)
                         create(:sub_service_request, service_request: service_request1, organization: organization1, status: 'draft', protocol_id: @protocol1.id)

      service_request2 = create(:service_request_without_validations, protocol: @protocol2)
                         create(:sub_service_request, service_request: service_request2, organization: organization2, status: 'draft', protocol_id: @protocol2.id)

      service_request3 = create(:service_request_without_validations, protocol: @protocol3)
                         create(:sub_service_request, service_request: service_request3, organization: organization3, status: 'draft', protocol_id: @protocol3.id)
    end

    it "should match against whole PRO#" do
      visit_protocols_index_page
      wait_for_javascript_to_finish

      expect(@page.search_results).to have_protocols(count: 3)

      @page.filter_protocols.select_search(@page, "PRO#", @protocol3.human_subjects_info.pro_number)
      @page.filter_protocols.apply_filter_button.click()
      wait_for_javascript_to_finish

      expect(@page.search_results).to have_no_protocols(text: "Protocol1")
      expect(@page.search_results).to have_no_protocols(text: "Protocol2")
      expect(@page.search_results).to have_protocols(text: "Protocol3")
    end

    it "should not have any PRO# matches" do
      visit_protocols_index_page
      wait_for_javascript_to_finish

      expect(@page.search_results).to have_protocols(count: 3)

      @page.filter_protocols.select_search(@page, "PRO#", "111111111")
      @page.filter_protocols.apply_filter_button.click()
      wait_for_javascript_to_finish

      expect(@page.search_results).to have_no_protocols(text: "Protocol1")
      expect(@page.search_results).to have_no_protocols(text: "Protocol2")
      expect(@page.search_results).to have_no_protocols(text: "Protocol3")
    end
  end



  context "All search" do
    before :each do
      organization1 = create(:organization)
      organization2 = create(:organization)
      organization3 = create(:organization)
      create(:service_provider, organization: organization1, identity: user)
      create(:service_provider, organization: organization2, identity: user)
      create(:service_provider, organization: organization3, identity: user)

      @protocol1 = create_protocol(id: 888888, archived: false, title: "titlex", short_title: "Protocol1")
      create(:project_role, identity: user, role: "very-important", project_rights: "to-party", protocol: @protocol1)

      @protocol2 = create_protocol(id: 777777, archived: false, title: "xTitle", short_title: "Protocol2")
      create(:project_role, identity: user, role: "very-important", project_rights: "to-party", protocol: @protocol2)

      @protocol3 = create_protocol(archived: false, title: "888888", short_title: "Protocol3", research_master_id: 999999)
      create(:project_role, identity: user2, role: "very-important", project_rights: "to-party", protocol: @protocol3)

      @protocol4 = create_protocol(type: 'Project', archived: false, title: '101010101', short_title: 'Protocol4')

      service_request1 = create(:service_request_without_validations, protocol: @protocol1)
                         create(:sub_service_request, service_request: service_request1, organization: organization1, status: 'draft', protocol_id: @protocol1.id)

      service_request2 = create(:service_request_without_validations, protocol: @protocol2)
                         create(:sub_service_request, service_request: service_request2, organization: organization2, status: 'draft', protocol_id: @protocol2.id)

      service_request3 = create(:service_request_without_validations, protocol: @protocol3)
                         create(:sub_service_request, service_request: service_request3, organization: organization3, status: 'draft', protocol_id: @protocol3.id)

      service_request4 = create(:service_request_without_validations, protocol: @protocol4)
                         create(:sub_service_request, service_request: service_request4, organization: organization3, status: 'draft', protocol_id: @protocol4.id)
    end

    ### SEARH ALL TITLE ###
    it "should match against title case insensitively (lowercase) and match protocol ID" do
      visit_protocols_index_page
      wait_for_javascript_to_finish

      expect(@page.search_results).to have_protocols(count: 4)

      @page.filter_protocols.search_field.set("888888")
      @page.filter_protocols.apply_filter_button.click()
      wait_for_javascript_to_finish

      expect(@page.search_results).to have_protocols(text: "Protocol1")
      expect(@page.search_results).to have_no_protocols(text: "Protocol2")
      expect(@page.search_results).to have_protocols(text: "Protocol3")
    end

    it "should match against whole short title case insensitively (uppercase)" do
      visit_protocols_index_page
      wait_for_javascript_to_finish

      expect(@page.search_results).to have_protocols(count: 4)

      @page.filter_protocols.search_field.set("Protocol1")
      @page.filter_protocols.apply_filter_button.click
      wait_for_javascript_to_finish

      expect(@page.search_results).to have_protocols(text: "Protocol1")
      expect(@page.search_results).to have_no_protocols(text: "Protocol2")
      expect(@page.search_results).to have_no_protocols(text: "Protocol3")
    end

    it "should match against partial short title case insensitively (uppercase)" do
      visit_protocols_index_page
      wait_for_javascript_to_finish

      expect(@page.search_results).to have_protocols(count: 4)

      @page.filter_protocols.search_field.set("Protocol")
      @page.filter_protocols.apply_filter_button.click
      wait_for_javascript_to_finish

      expect(@page.search_results).to have_protocols(text: "Protocol1")
      expect(@page.search_results).to have_protocols(text: "Protocol2")
      expect(@page.search_results).to have_protocols(text: "Protocol3")
    end

    it "should match against displaying special characters" do
      @protocol1.update_attribute(:short_title, "title %")
      @protocol2.update_attribute(:short_title, "_Title")
      @protocol3.update_attribute(:short_title, "a%a")

      visit_protocols_index_page
      wait_for_javascript_to_finish

      expect(@page.search_results).to have_protocols(count: 4)

      @page.filter_protocols.search_field.set("%")
      @page.filter_protocols.apply_filter_button.click()
      wait_for_javascript_to_finish

      expect(@page.search_results).to have_protocols(text: "title %")
      expect(@page.search_results).to have_no_protocols(text: "_Title")
      expect(@page.search_results).to have_protocols(text: "a%a")
    end

    it 'should return projects and not just studies' do
      visit_protocols_index_page
      wait_for_javascript_to_finish

      expect(@page.search_results).to have_protocols(count: 4)

      @page.filter_protocols.search_field.set("101")
      @page.filter_protocols.apply_filter_button.click
      wait_for_javascript_to_finish

      expect(@page.search_results).to have_protocols(text: "Protocol4")
    end

    ### SEARH ALL PROTOCOL ID ###
    it "should match against id" do
      visit_protocols_index_page
      wait_for_javascript_to_finish

      expect(@page.search_results).to have_protocols(count: 4)

      @page.filter_protocols.search_field.set(777777)
      @page.filter_protocols.apply_filter_button.click
      wait_for_javascript_to_finish

      expect(@page.search_results).to have_protocols(count: 1)
      expect(@page.search_results).to have_protocols(text: "Protocol2")
    end

    ### SEARH ALL USERS ###
    it "should match against associated users first name case insensitively (lowercase)" do
      visit_protocols_index_page
      wait_for_javascript_to_finish

      expect(@page.search_results).to have_protocols(count: 4)

      @page.filter_protocols.search_field.set("james")
      @page.filter_protocols.apply_filter_button.click()
      wait_for_javascript_to_finish

      expect(@page.search_results).to have_no_protocols(text: "Protocol1")
      expect(@page.search_results).to have_no_protocols(text: "Protocol2")
      expect(@page.search_results).to have_protocols(text: "Protocol3")
    end

    it "should match against associated users last name case insensitively (uppercase)" do
      visit_protocols_index_page
      wait_for_javascript_to_finish

      expect(@page.search_results).to have_protocols(count: 4)

      @page.filter_protocols.search_field.set("Doop")
      @page.filter_protocols.apply_filter_button.click()
      wait_for_javascript_to_finish

      expect(@page.search_results).to have_no_protocols(text: "Protocol1")
      expect(@page.search_results).to have_no_protocols(text: "Protocol2")
      expect(@page.search_results).to have_protocols(text: "Protocol3")
    end

    it "should not have any matches" do
      visit_protocols_index_page
      wait_for_javascript_to_finish

      expect(@page.search_results).to have_protocols(count: 4)

      @page.filter_protocols.search_field.set("Hedwig")
      @page.filter_protocols.apply_filter_button.click()
      wait_for_javascript_to_finish

      expect(@page.search_results).to have_no_protocols(text: "Protocol1")
      expect(@page.search_results).to have_no_protocols(text: "Protocol2")
      expect(@page.search_results).to have_no_protocols(text: "Protocol3")
    end

    it "should match against pi first name case insensitively (lowercase)" do
      visit_protocols_index_page
      wait_for_javascript_to_finish

      expect(@page.search_results).to have_protocols(count: 4)

      @page.filter_protocols.search_field.set((@protocol3.principal_investigators.first.first_name.downcase).to_s)
      @page.filter_protocols.apply_filter_button.click()
      wait_for_javascript_to_finish

      expect(@page.search_results).to have_no_protocols(text: "Protocol1")
      expect(@page.search_results).to have_no_protocols(text: "Protocol2")
      expect(@page.search_results).to have_protocols(text: "Protocol3")
    end

    it "should match against pi last name case insensitively (uppercase)" do
      visit_protocols_index_page
      wait_for_javascript_to_finish

      expect(@page.search_results).to have_protocols(count: 4)

      @page.filter_protocols.search_field.set((@protocol3.principal_investigators.first.last_name).to_s)
      @page.filter_protocols.apply_filter_button.click()
      wait_for_javascript_to_finish

      expect(@page.search_results).to have_no_protocols(text: "Protocol1")
      expect(@page.search_results).to have_no_protocols(text: "Protocol2")
      expect(@page.search_results).to have_protocols(text: "Protocol3")
    end

    it "should not have any matches" do
      visit_protocols_index_page
      wait_for_javascript_to_finish

      expect(@page.search_results).to have_protocols(count: 4)

      @page.filter_protocols.search_field.set("Johnbob")
      @page.filter_protocols.apply_filter_button.click()
      wait_for_javascript_to_finish

      expect(@page.search_results).to have_no_protocols(text: "Protocol1")
      expect(@page.search_results).to have_no_protocols(text: "Protocol2")
      expect(@page.search_results).to have_no_protocols(text: "Protocol3")
    end
  end
end
