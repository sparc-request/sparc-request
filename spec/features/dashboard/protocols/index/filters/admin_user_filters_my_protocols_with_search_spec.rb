# Copyright © 2011-2018 MUSC Foundation for Research Development~
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

RSpec.describe "Admin User filters My Protocols using Search functionality", js: :true do

  let_there_be_lane
  fake_login_for_each_test

  let!(:other_user)     { create(:identity, first_name: 'John', last_name: 'Doe') }
  
  let!(:organization1)  { create(:organization) }
  let!(:organization2)  { create(:organization) }
  let!(:organization3)  { create(:organization) }
  let!(:sp1)            { create(:service_provider, identity: jug2, organization: organization1) }
  let!(:sp2)            { create(:service_provider, identity: jug2, organization: organization2) }
  let!(:sp3)            { create(:service_provider, identity: jug2, organization: organization3) }

  context "Short/Long Title search" do
    before :each do
      @protocol1 = create(:study_without_validations, primary_pi: jug2, title: "title%", short_title: "Protocol1")
      @protocol2 = create(:study_without_validations, primary_pi: jug2, title: "xTitle", short_title: "Protocol2")
      @protocol3 = create(:study_without_validations, primary_pi: jug2, title: "a%a", short_title: "Protocol3")

      service_request1 = create(:service_request_without_validations, protocol: @protocol1)
      service_request2 = create(:service_request_without_validations, protocol: @protocol2)
      service_request3 = create(:service_request_without_validations, protocol: @protocol3)

      visit dashboard_protocols_path
      wait_for_javascript_to_finish

      find("#filterrific_admin_filter_for_identity_#{jug2.id}").click
      find('#apply-filter-button').click
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
      @protocol1 = create(:study_without_validations, primary_pi: jug2, title: "title%", short_title: "Protocol1")
      @protocol2 = create(:study_without_validations, primary_pi: jug2, title: "xTitle", short_title: "Protocol2")
      @protocol3 = create(:study_without_validations, primary_pi: jug2, title: "a%a", short_title: "Protocol3")

      service_request1 = create(:service_request_without_validations, protocol: @protocol1)
      service_request2 = create(:service_request_without_validations, protocol: @protocol2)
      service_request3 = create(:service_request_without_validations, protocol: @protocol3)

      visit dashboard_protocols_path
      wait_for_javascript_to_finish

      find("#filterrific_admin_filter_for_identity_#{jug2.id}").click
      find('#apply-filter-button').click
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
      @protocol1 = create(:study_without_validations, primary_pi: jug2, title: "title%", short_title: "Protocol1")
      @protocol2 = create(:study_without_validations, primary_pi: jug2, title: "xTitle", short_title: "Protocol2")
      @protocol3 = create(:study_without_validations, primary_pi: jug2, title: "a%a", short_title: "Protocol3")

      create(:project_role, protocol: @protocol3, identity: other_user, project_rights: 'view', role: 'consultant') 

      service_request1 = create(:service_request_without_validations, protocol: @protocol1)
      service_request2 = create(:service_request_without_validations, protocol: @protocol2)
      service_request3 = create(:service_request_without_validations, protocol: @protocol3)

      visit dashboard_protocols_path
      wait_for_javascript_to_finish

      find("#filterrific_admin_filter_for_identity_#{jug2.id}").click
      find('#apply-filter-button').click
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
      @protocol1 = create(:study_without_validations, primary_pi: jug2, title: "title%", short_title: "Protocol1")
      @protocol2 = create(:study_without_validations, primary_pi: jug2, title: "xTitle", short_title: "Protocol2")
      @protocol3 = create(:study_without_validations, primary_pi: other_user, title: "a%a", short_title: "Protocol3")

      service_request1 = create(:service_request_without_validations, protocol: @protocol1)
      service_request2 = create(:service_request_without_validations, protocol: @protocol2)
      service_request3 = create(:service_request_without_validations, protocol: @protocol3)

      create(:project_role, identity: jug2, protocol: @protocol3, project_rights: 'view', role: 'consultant')

      visit dashboard_protocols_path
      wait_for_javascript_to_finish

      find("#filterrific_admin_filter_for_identity_#{jug2.id}").click
      find('#apply-filter-button').click
      wait_for_javascript_to_finish

      expect(page).to have_selector(".protocols_index_row", count: 3)
    end

    it "should match against pi first name case insensitively (lowercase)" do
      bootstrap_select '#filterrific_search_query_search_drop', 'PI'
      fill_in 'filterrific_search_query_search_text', with: other_user.first_name.downcase
      find('#apply-filter-button').click
      wait_for_javascript_to_finish

      expect(page).to have_selector(".protocols_index_row", count: 1)
      expect(page).to_not have_content(@protocol1.short_title)
      expect(page).to_not have_content(@protocol2.short_title)
      expect(page).to have_content(@protocol3.short_title)
    end

    it "should match against pi last name case insensitively (uppercase)" do
      bootstrap_select '#filterrific_search_query_search_drop', 'PI'
      fill_in 'filterrific_search_query_search_text', with: other_user.first_name
      find('#apply-filter-button').click
      wait_for_javascript_to_finish

      expect(page).to have_selector(".protocols_index_row", count: 1)
      expect(page).to_not have_content(@protocol1.short_title)
      expect(page).to_not have_content(@protocol2.short_title)
      expect(page).to have_content(@protocol3.short_title)
    end

    it "should not have any matches" do
      bootstrap_select '#filterrific_search_query_search_drop', 'PI'
      fill_in 'filterrific_search_query_search_text', with: 'Darth Vader'
      find('#apply-filter-button').click
      wait_for_javascript_to_finish

      expect(page).to have_selector(".protocols_index_row", count: 0)
      expect(page).to_not have_content(@protocol1.short_title)
      expect(page).to_not have_content(@protocol2.short_title)
      expect(page).to_not have_content(@protocol3.short_title)
    end
  end



  context "RMID search" do
    context 'RMID enabled' do
      stub_config('research_master_enabled', true)
      before :each do
        @protocol1 = create(:study_without_validations, primary_pi: jug2, title: "title%", short_title: "Protocol1")
        @protocol2 = create(:study_without_validations, primary_pi: jug2, title: "xTitle", short_title: "Protocol2")
        @protocol3 = create(:study_without_validations, primary_pi: jug2, title: "a%a", short_title: "Protocol3", research_master_id: 1234)

        service_request1 = create(:service_request_without_validations, protocol: @protocol1)
        service_request2 = create(:service_request_without_validations, protocol: @protocol2)
        service_request3 = create(:service_request_without_validations, protocol: @protocol3)

        visit dashboard_protocols_path
        wait_for_javascript_to_finish

        find("#filterrific_admin_filter_for_identity_#{jug2.id}").click
        find('#apply-filter-button').click
        wait_for_javascript_to_finish

        expect(page).to have_selector(".protocols_index_row", count: 3)
      end

      it "should match against RMID" do
        bootstrap_select '#filterrific_search_query_search_drop', 'RMID'
        fill_in 'filterrific_search_query_search_text', with: @protocol3.research_master_id
        find('#apply-filter-button').click
        wait_for_javascript_to_finish

        expect(page).to have_selector(".protocols_index_row", count: 1)
        expect(page).to_not have_content(@protocol1.short_title)
        expect(page).to_not have_content(@protocol2.short_title)
        expect(page).to have_content(@protocol3.short_title)
      end
    end

    context 'RMID disabled' do
      stub_config('research_master_enabled', false)
      before :each do
        @protocol1 = create(:study_without_validations, primary_pi: jug2, title: "title%", short_title: "Protocol1")
        @protocol2 = create(:study_without_validations, primary_pi: jug2, title: "xTitle", short_title: "Protocol2")
        @protocol3 = create(:study_without_validations, primary_pi: jug2, title: "a%a", short_title: "Protocol3", research_master_id: 1234)

        service_request1 = create(:service_request_without_validations, protocol: @protocol1)
        service_request2 = create(:service_request_without_validations, protocol: @protocol2)
        service_request3 = create(:service_request_without_validations, protocol: @protocol3)

        visit dashboard_protocols_path
        wait_for_javascript_to_finish

        find("#filterrific_admin_filter_for_identity_#{jug2.id}").click
        find('#apply-filter-button').click
        wait_for_javascript_to_finish

        expect(page).to have_selector(".protocols_index_row", count: 3)
      end

      it "should not display RMID as a filter option" do
        bootstrap_select = page.find("select#filterrific_search_query_search_drop + .bootstrap-select")
        bootstrap_select.click
        expect(page).to_not have_content('RMID')
      end
    end
  end

  context "HR# search" do
    before :each do
      hsi1       = create(:human_subjects_info, hr_number: 111111)
      hsi2       = create(:human_subjects_info, hr_number: 222222)
      hsi3       = create(:human_subjects_info, hr_number: 333333)

      @protocol1 = create(:study_without_validations, primary_pi: jug2, title: "title%", short_title: "Protocol1", human_subjects_info: hsi1)
      @protocol2 = create(:study_without_validations, primary_pi: jug2, title: "xTitle", short_title: "Protocol2", human_subjects_info: hsi2)
      @protocol3 = create(:study_without_validations, primary_pi: jug2, title: "a%a", short_title: "Protocol3", human_subjects_info: hsi3)

      service_request1 = create(:service_request_without_validations, protocol: @protocol1)
      service_request2 = create(:service_request_without_validations, protocol: @protocol2)
      service_request3 = create(:service_request_without_validations, protocol: @protocol3)

      visit dashboard_protocols_path
      wait_for_javascript_to_finish

      find("#filterrific_admin_filter_for_identity_#{jug2.id}").click
      find('#apply-filter-button').click
      wait_for_javascript_to_finish

      expect(page).to have_selector(".protocols_index_row", count: 3)
    end

    it "should match against whole HR#" do
      bootstrap_select '#filterrific_search_query_search_drop', 'HR#'
      fill_in 'filterrific_search_query_search_text', with: @protocol3.human_subjects_info.hr_number
      find('#apply-filter-button').click
      wait_for_javascript_to_finish

      expect(page).to have_selector(".protocols_index_row", count: 1)
      expect(page).to_not have_content(@protocol1.short_title)
      expect(page).to_not have_content(@protocol2.short_title)
      expect(page).to have_content(@protocol3.short_title)
    end

    it "should match against partial HR#" do
      bootstrap_select '#filterrific_search_query_search_drop', 'HR#'
      fill_in 'filterrific_search_query_search_text', with: @protocol3.human_subjects_info.hr_number.split(//, 2).last
      find('#apply-filter-button').click
      wait_for_javascript_to_finish

      expect(page).to have_selector(".protocols_index_row", count: 1)
      expect(page).to_not have_content(@protocol1.short_title)
      expect(page).to_not have_content(@protocol2.short_title)
      expect(page).to have_content(@protocol3.short_title)
    end

    it "should not have any HR# matches" do
      bootstrap_select '#filterrific_search_query_search_drop', 'HR#'
      fill_in 'filterrific_search_query_search_text', with: '123123'
      find('#apply-filter-button').click
      wait_for_javascript_to_finish

      expect(page).to have_selector(".protocols_index_row", count: 0)
      expect(page).to_not have_content(@protocol1.short_title)
      expect(page).to_not have_content(@protocol2.short_title)
      expect(page).to_not have_content(@protocol3.short_title)
    end
  end



  context "PRO# search" do
    before :each do
      @protocol1 = create(:study_without_validations, primary_pi: jug2, title: "title%", short_title: "Protocol1")
      @protocol2 = create(:study_without_validations, primary_pi: jug2, title: "xTitle", short_title: "Protocol2")
      @protocol3 = create(:study_without_validations, primary_pi: jug2, title: "a%a", short_title: "Protocol3")

      service_request1 = create(:service_request_without_validations, protocol: @protocol1)
      service_request2 = create(:service_request_without_validations, protocol: @protocol2)
      service_request3 = create(:service_request_without_validations, protocol: @protocol3)

      visit dashboard_protocols_path
      wait_for_javascript_to_finish

      find("#filterrific_admin_filter_for_identity_#{jug2.id}").click
      find('#apply-filter-button').click
      wait_for_javascript_to_finish

      expect(page).to have_selector(".protocols_index_row", count: 3)
    end

    it "should match against whole PRO#" do
      bootstrap_select '#filterrific_search_query_search_drop', 'PRO#'
      fill_in 'filterrific_search_query_search_text', with: @protocol3.human_subjects_info.pro_number
      find('#apply-filter-button').click
      wait_for_javascript_to_finish

      expect(page).to have_selector(".protocols_index_row", count: 1)
      expect(page).to_not have_content(@protocol1.short_title)
      expect(page).to_not have_content(@protocol2.short_title)
      expect(page).to have_content(@protocol3.short_title)
    end

    it "should not have any PRO# matches" do
      bootstrap_select '#filterrific_search_query_search_drop', 'PRO#'
      fill_in 'filterrific_search_query_search_text', with: '123123'
      find('#apply-filter-button').click
      wait_for_javascript_to_finish

      expect(page).to have_selector(".protocols_index_row", count: 0)
      expect(page).to_not have_content(@protocol1.short_title)
      expect(page).to_not have_content(@protocol2.short_title)
      expect(page).to_not have_content(@protocol3.short_title)
    end
  end



  context "All search" do
    before :each do
      hsi1       = create(:human_subjects_info, hr_number: 111111)
      hsi2       = create(:human_subjects_info, hr_number: 222222)
      hsi3       = create(:human_subjects_info, hr_number: 333333)

      @protocol1 = create(:study_without_validations, id: 555555, primary_pi: jug2, title: "title%", short_title: "Protocol1", human_subjects_info: hsi1)
      @protocol2 = create(:study_without_validations, id: 666666, primary_pi: jug2, title: "xTitle", short_title: "Protocol2", human_subjects_info: hsi2)
      @protocol3 = create(:study_without_validations, id: 777777, primary_pi: other_user, title: @protocol1.id.to_s, short_title: "Protocol3", research_master_id: 1234, human_subjects_info: hsi3)
      @protocol4 = create(:project_without_validations, id: 888888, primary_pi: jug2, title: "TheRubyRacer", short_title: "Protocol4")
      
      service_request1 = create(:service_request_without_validations, protocol: @protocol1)
      service_request2 = create(:service_request_without_validations, protocol: @protocol2)
      service_request3 = create(:service_request_without_validations, protocol: @protocol3)
      service_request4 = create(:service_request_without_validations, protocol: @protocol3)

      create(:project_role, identity: jug2, protocol: @protocol3, project_rights: 'view', role: 'consultant')

      visit dashboard_protocols_path
      wait_for_javascript_to_finish

      find("#filterrific_admin_filter_for_identity_#{jug2.id}").click
      find('#apply-filter-button').click
      wait_for_javascript_to_finish

      expect(page).to have_selector(".protocols_index_row", count: 4)
    end

    context 'Short/Long Title' do
      it "should match against title case insensitively (lowercase) and match protocol ID" do
        fill_in 'filterrific_search_query_search_text', with: @protocol3.title
        find('#apply-filter-button').click
        wait_for_javascript_to_finish

        expect(page).to have_selector(".protocols_index_row", count: 2)
        expect(page).to have_content(@protocol1.short_title)
        expect(page).to_not have_content(@protocol2.short_title)
        expect(page).to have_content(@protocol3.short_title)
        expect(page).to_not have_content(@protocol4.short_title)
      end

      it "should match against whole short title case insensitively (uppercase)" do
        fill_in 'filterrific_search_query_search_text', with: 'Protocol1'
        find('#apply-filter-button').click
        wait_for_javascript_to_finish

        expect(page).to have_selector(".protocols_index_row", count: 1)
        expect(page).to have_content(@protocol1.short_title)
        expect(page).to_not have_content(@protocol2.short_title)
        expect(page).to_not have_content(@protocol3.short_title)
        expect(page).to_not have_content(@protocol4.short_title)
      end

      it "should match against partial short title case insensitively (uppercase)" do
        fill_in 'filterrific_search_query_search_text', with: 'Protocol'
        find('#apply-filter-button').click
        wait_for_javascript_to_finish

        expect(page).to have_selector(".protocols_index_row", count: 4)
        expect(page).to have_content(@protocol1.short_title)
        expect(page).to have_content(@protocol2.short_title)
        expect(page).to have_content(@protocol3.short_title)
        expect(page).to have_content(@protocol4.short_title)
      end

      it "should match against displaying special characters" do
        fill_in 'filterrific_search_query_search_text', with: '%'
        find('#apply-filter-button').click
        wait_for_javascript_to_finish

        expect(page).to have_selector(".protocols_index_row", count: 1)
        expect(page).to have_content(@protocol1.short_title)
        expect(page).to_not have_content(@protocol2.short_title)
        expect(page).to_not have_content(@protocol3.short_title)
        expect(page).to_not have_content(@protocol4.short_title)
      end
    end

    context 'Protocol ID' do
      it "should match against id" do
        fill_in 'filterrific_search_query_search_text', with: @protocol2.id
        find('#apply-filter-button').click
        wait_for_javascript_to_finish

        expect(page).to have_selector(".protocols_index_row", count: 1)
        expect(page).to_not have_content(@protocol1.short_title)
        expect(page).to have_content(@protocol2.short_title)
        expect(page).to_not have_content(@protocol3.short_title)
        expect(page).to_not have_content(@protocol4.short_title)
      end
    end

    context 'Authorized User' do
      it "should match against associated users first name case insensitively (lowercase)" do
        fill_in 'filterrific_search_query_search_text', with: other_user.first_name.downcase
        find('#apply-filter-button').click
        wait_for_javascript_to_finish

        expect(page).to have_selector(".protocols_index_row", count: 1)
        expect(page).to_not have_content(@protocol1.short_title)
        expect(page).to_not have_content(@protocol2.short_title)
        expect(page).to have_content(@protocol3.short_title)
        expect(page).to_not have_content(@protocol4.short_title)
      end

      it "should match against associated users last name case insensitively (uppercase)" do
        fill_in 'filterrific_search_query_search_text', with: other_user.first_name
        find('#apply-filter-button').click
        wait_for_javascript_to_finish

        expect(page).to have_selector(".protocols_index_row", count: 1)
        expect(page).to_not have_content(@protocol1.short_title)
        expect(page).to_not have_content(@protocol2.short_title)
        expect(page).to have_content(@protocol3.short_title)
        expect(page).to_not have_content(@protocol4.short_title)
      end

      it "should not have any matches" do
        fill_in 'filterrific_search_query_search_text', with: 'Darth Vader'
        find('#apply-filter-button').click
        wait_for_javascript_to_finish

        expect(page).to have_selector(".protocols_index_row", count: 0)
        expect(page).to_not have_content(@protocol1.short_title)
        expect(page).to_not have_content(@protocol2.short_title)
        expect(page).to_not have_content(@protocol3.short_title)
        expect(page).to_not have_content(@protocol4.short_title)
      end
    end

    context 'PI' do
      it "should match against pi first name case insensitively (lowercase)" do
        fill_in 'filterrific_search_query_search_text', with: other_user.first_name.downcase
        find('#apply-filter-button').click
        wait_for_javascript_to_finish

        expect(page).to have_selector(".protocols_index_row", count: 1)
        expect(page).to_not have_content(@protocol1.short_title)
        expect(page).to_not have_content(@protocol2.short_title)
        expect(page).to have_content(@protocol3.short_title)
        expect(page).to_not have_content(@protocol4.short_title)
      end

      it "should match against pi last name case insensitively (uppercase)" do
        fill_in 'filterrific_search_query_search_text', with: other_user.first_name
        find('#apply-filter-button').click
        wait_for_javascript_to_finish
        
        expect(page).to have_selector(".protocols_index_row", count: 1)
        expect(page).to_not have_content(@protocol1.short_title)
        expect(page).to_not have_content(@protocol2.short_title)
        expect(page).to have_content(@protocol3.short_title)
        expect(page).to_not have_content(@protocol4.short_title)
      end

      it "should not have any matches" do
        fill_in 'filterrific_search_query_search_text', with: 'Darth Vader'
        find('#apply-filter-button').click
        wait_for_javascript_to_finish
        
        expect(page).to have_selector(".protocols_index_row", count: 0)
        expect(page).to_not have_content(@protocol1.short_title)
        expect(page).to_not have_content(@protocol2.short_title)
        expect(page).to_not have_content(@protocol3.short_title)
        expect(page).to_not have_content(@protocol4.short_title)
      end
    end

    context 'RMID' do
      it 'should match against RMID' do
        fill_in 'filterrific_search_query_search_text', with: @protocol3.research_master_id
        find('#apply-filter-button').click
        wait_for_javascript_to_finish
        
        expect(page).to have_selector(".protocols_index_row", count: 1)
        expect(page).to_not have_content(@protocol1.short_title)
        expect(page).to_not have_content(@protocol2.short_title)
        expect(page).to have_content(@protocol3.short_title)
        expect(page).to_not have_content(@protocol4.short_title)
      end
    end

    context 'HR#' do
      it "should match against whole HR#" do
        fill_in 'filterrific_search_query_search_text', with: @protocol1.human_subjects_info.hr_number
        find('#apply-filter-button').click
        wait_for_javascript_to_finish

        expect(page).to have_selector(".protocols_index_row", count: 1)
        expect(page).to have_content(@protocol1.short_title)
        expect(page).to_not have_content(@protocol2.short_title)
        expect(page).to_not have_content(@protocol3.short_title)
        expect(page).to_not have_content(@protocol4.short_title)
      end

      it "should match against partial HR#" do
        fill_in 'filterrific_search_query_search_text', with: @protocol1.human_subjects_info.hr_number.split(//, 2).last
        find('#apply-filter-button').click
        wait_for_javascript_to_finish

        expect(page).to have_selector(".protocols_index_row", count: 1)
        expect(page).to have_content(@protocol1.short_title)
        expect(page).to_not have_content(@protocol2.short_title)
        expect(page).to_not have_content(@protocol3.short_title)
        expect(page).to_not have_content(@protocol4.short_title)
      end

      it "should not have any HR# matches" do
        fill_in 'filterrific_search_query_search_text', with: '123123'
        find('#apply-filter-button').click
        wait_for_javascript_to_finish

        expect(page).to have_selector(".protocols_index_row", count: 0)
        expect(page).to_not have_content(@protocol1.short_title)
        expect(page).to_not have_content(@protocol2.short_title)
        expect(page).to_not have_content(@protocol3.short_title)
        expect(page).to_not have_content(@protocol4.short_title)
      end
    end

    context 'PRO#' do
      it "should match against whole PRO#" do
        fill_in 'filterrific_search_query_search_text', with: @protocol1.human_subjects_info.pro_number
        find('#apply-filter-button').click
        wait_for_javascript_to_finish

        expect(page).to have_selector(".protocols_index_row", count: 1)
        expect(page).to have_content(@protocol1.short_title)
        expect(page).to_not have_content(@protocol2.short_title)
        expect(page).to_not have_content(@protocol3.short_title)
        expect(page).to_not have_content(@protocol4.short_title)
      end

      it "should not have any PRO# matches" do
        fill_in 'filterrific_search_query_search_text', with: '123123'
        find('#apply-filter-button').click
        wait_for_javascript_to_finish

        expect(page).to have_selector(".protocols_index_row", count: 0)
        expect(page).to_not have_content(@protocol1.short_title)
        expect(page).to_not have_content(@protocol2.short_title)
        expect(page).to_not have_content(@protocol3.short_title)
        expect(page).to_not have_content(@protocol4.short_title)
      end
    end

    it 'should return projects and not just studies' do
      fill_in 'filterrific_search_query_search_text', with: 'Ruby'
      find('#apply-filter-button').click
      wait_for_javascript_to_finish
      
      expect(page).to have_selector(".protocols_index_row", count: 1)
      expect(page).to_not have_content(@protocol1.short_title)
      expect(page).to_not have_content(@protocol2.short_title)
      expect(page).to_not have_content(@protocol3.short_title)
      expect(page).to have_content(@protocol4.short_title)
    end
  end
end
