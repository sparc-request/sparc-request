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

RSpec.describe "filters", js: :true do
  let!(:user) do
    create(:identity,
      last_name: "Doe",
      first_name: "John",
      ldap_uid: "johnd",
      email: "johnd@musc.edu",
      password: "p4ssword",
      password_confirmation: "p4ssword",
      approved: true)
  end

  let!(:user2) do
    create(:identity,
      last_name: "Doop",
      first_name: "James",
      ldap_uid: "jamesd",
      email: "jamesd@musc.edu",
      password: "p4ssword",
      password_confirmation: "p4ssword",
      approved: true)
  end

  fake_login_for_each_test("johnd")

  def visit_protocols_index_page
    @page = Dashboard::Protocols::IndexPage.new
    @page.load
  end

  describe "default" do
    it "should display unarchived Protocols with SubServiceRequests of any status for which the user has a ProjectRole without 'none' rights" do
      protocol = create_protocol(archived: false, status: "single-ready-to-mingle")
      protocol.project_roles.create(identity_id: user.id,
        role: "very-important",
        project_rights: "not-none")

      visit_protocols_index_page
      wait_for_javascript_to_finish

      expect(@page.search_results).to have_protocols
    end
  end

  describe "save" do
    context "user clicks save" do
      it "should allow user to save filter" do
        organization = create(:institution, name: 'Union Allied')
        create(:service_provider, organization_id: organization.id, identity_id: user.id)
        protocol = create_protocol(archived: false, short_title: "Shady Business", organization: organization)

        visit_protocols_index_page
        wait_for_javascript_to_finish

        expect do
          @page.instance_exec do
            filter_protocols.archived_checkbox.click
            filter_protocols.select_status("Active", "Complete")
            filter_protocols.select_core("Union Allied")
            filter_protocols.save_link.click
            wait_for_filter_form_modal
            filter_form_modal.name_field.set("MyFilter")
            filter_form_modal.save_button.click
          end
          expect(@page.recently_saved_filters).to have_filters(text: "MyFilter")
        end.to change { ProtocolFilter.count }.by(1)

        new_filter = ProtocolFilter.last
        expect(new_filter.with_status).to eq(['ctrc_approved', 'complete'])
        expect(new_filter.with_organization).to eq(["#{organization.id}"])
        expect(new_filter.show_archived).to eq(true)
      end
    end

    context "admin user clicks save" do
      it "should allow admin user to save filter" do
        organization = create(:institution, name: 'Union Allied')
        create(:service_provider, organization_id: organization.id, identity_id: user.id)
        protocol = create_protocol(archived: false, short_title: "Shady Business", organization: organization)

        visit_protocols_index_page
        wait_for_javascript_to_finish

        expect do
          @page.instance_exec do
            filter_protocols.archived_checkbox.click
            filter_protocols.select_status("Active", "Complete")
            filter_protocols.select_core("Union Allied")
            filter_protocols.select_owner("Doe, John")
            filter_protocols.save_link.click
            wait_for_filter_form_modal
            filter_form_modal.name_field.set("MyFilter")
            filter_form_modal.save_button.click
          end
          expect(@page.recently_saved_filters).to have_filters(text: "MyFilter")
        end.to change { ProtocolFilter.count }.by(1)

        new_filter = ProtocolFilter.last
        expect(new_filter.with_status).to eq(['ctrc_approved', 'complete'])
        expect(new_filter.show_archived).to eq(true)
        expect(new_filter.with_organization).to eq(["#{organization.id}"])
        expect(new_filter.with_owner).to eq(["#{user.id}"])
      end
    end
  end

  describe "recently saved filters" do
    context "user has saved filters and clicks a saved filter name" do
      it "should apply that filter" do
        # archived, has status "Complete"
        protocol1 = create_protocol(archived: true, short_title: "ArchivedComplete", status: "complete")
        protocol1.project_roles.create(identity_id: user.id, role: "very-important", project_rights: "to-party")

        # archived, has status "Active" (ctrc_approved...)
        protocol2 = create_protocol(archived: true, short_title: "ArchivedActive", status: "ctrc_approved")
        protocol2.project_roles.create(identity_id: user.id, role: "very-important", project_rights: "to-party")

        # unarchived, has status "Active"
        protocol3 = create_protocol(archived: false, short_title: "UnarchivedActive", status: "ctrc_approved")
        protocol3.project_roles.create(identity_id: user.id, role: "very-important", project_rights: "to-party")

        # archived, has status "Draft"
        protocol4 = create_protocol(archived: true, short_title: "ArchivedDraft", status: "draft")
        protocol4.project_roles.create(identity_id: user.id, role: "very-important", project_rights: "to-party")

        f = ProtocolFilter.create(search_name: "MyFilter",
          show_archived: true,
          for_admin: false,
          for_identity_id: true,
          search_query: "",
          with_status: ['ctrc_approved', 'complete'])
        f.identity = user
        f.save!

        visit_protocols_index_page
        wait_for_javascript_to_finish

        @page.recently_saved_filters.filters.first.click
        wait_for_javascript_to_finish

        expect(@page.search_results).to have_protocols(text: "ArchivedComplete")
        expect(@page.search_results).to have_protocols(text: "ArchivedActive")
        expect(@page.search_results).to have_no_protocols(text: "UnarchivedActive")
        expect(@page.search_results).to have_no_protocols(text: "ArchivedDraft")
      end
    end
  end

  describe "reset" do
    it "should remove all filters" do
      archived_protocol = create_protocol(archived: true, short_title: "ArchivedProject")
      archived_protocol.project_roles.create(identity_id: user.id, role: "very-important", project_rights: "to-party")
      unarchived_protocol = create_protocol(archived: false, short_title: "UnarchivedProject")
      unarchived_protocol.project_roles.create(identity_id: user.id, role: "very-important", project_rights: "to-party")

      visit_protocols_index_page
      wait_for_javascript_to_finish

      @page.filter_protocols.archived_checkbox.click
      @page.filter_protocols.apply_filter_button.click
      @page.filter_protocols.reset_link.click
      wait_for_javascript_to_finish

      expect(@page.search_results).to have_protocols(text: "UnarchivedProject")
      expect(@page.search_results).to have_no_protocols(text: "ArchivedProject")
    end
  end

  describe "archived checkbox" do
    context "user checks archived checkbox and clicks filter button" do
      it "should only show archived protocols" do
        archived_protocol = create_protocol(archived: true, short_title: "ArchivedProject")
        archived_protocol.project_roles.create(identity_id: user.id, role: "very-important", project_rights: "to-party")
        unarchived_protocol = create_protocol(archived: false, short_title: "UnarchivedProject")
        unarchived_protocol.project_roles.create(identity_id: user.id, role: "very-important", project_rights: "to-party")

        visit_protocols_index_page
        wait_for_javascript_to_finish

        @page.filter_protocols.archived_checkbox.set(true)
        @page.filter_protocols.apply_filter_button.click
        wait_for_javascript_to_finish

        expect(@page.search_results).to have_protocols(text: "ArchivedProject")
        expect(@page.search_results).to have_no_protocols(text: "UnarchivedProject")
      end
    end
  end

  describe "status dropdown" do
    context "user selects multiple statuses from dropdown and clicks the filter button" do
      it "should display only Protocols that have a SubServiceRequest of those statuses" do
        no_ssr_protocol = create_protocol(archived: false, short_title: "NoSubServiceRequests")
        no_ssr_protocol.project_roles.create(identity_id: user.id, role: "very-important", project_rights: "to-party")

        approved_protocol = create_protocol(archived: false, short_title: "ApprovedProtocol", status: "approved")
        approved_protocol.project_roles.create(identity_id: user.id, role: "very-important", project_rights: "to-party")

        active_protocol = create_protocol(archived: false, short_title: "ActiveProtocol", status: "ctrc_approved")
        active_protocol.project_roles.create(identity_id: user.id, role: "very-important", project_rights: "to-party")

        draft_protocol = create_protocol(archived: false, short_title: "DraftProtocol", status: "draft")
        draft_protocol.project_roles.create(identity_id: user.id, role: "very-important", project_rights: "to-party")

        visit_protocols_index_page
        wait_for_javascript_to_finish

        @page.filter_protocols.select_status("Approved", "Active")
        @page.filter_protocols.apply_filter_button.click
        wait_for_javascript_to_finish

        expect(@page.search_results).to have_protocols(count: 2)
        expect(@page.search_results).to have_no_protocols(text: "NoSubServiceRequests")
        expect(@page.search_results).to have_protocols(text: "ApprovedProtocol")
        expect(@page.search_results).to have_protocols(text: "ActiveProtocol")
        expect(@page.search_results).to have_no_protocols(text: "DraftProtocol")
      end
    end
  end

  describe "search" do
    context "Short/Long Title search" do
      before :each do
        organization1 = create(:organization)
        organization2 = create(:organization)
        organization3 = create(:organization)
        create(:service_provider, organization: organization1, identity: user)
        create(:service_provider, organization: organization2, identity: user)
        create(:service_provider, organization: organization3, identity: user)

        @protocol1 = create_protocol(archived: false, title: "titlex", short_title: "Protocol1")
        create(:project_role, identity: user, role: "very-important", project_rights: "to-party", protocol: @protocol1)

        @protocol2 = create_protocol(archived: false, title: "xTitle", short_title: "Protocol2")
        create(:project_role, identity: user, role: "very-important", project_rights: "to-party", protocol: @protocol2)

        @protocol3 = create_protocol(archived: false, title: "aaa", short_title: "Protocol3")
        create(:project_role, identity: user, role: "very-important", project_rights: "to-party", protocol: @protocol3)

        service_request1 = create(:service_request_without_validations, protocol: @protocol1)
                           create(:sub_service_request, service_request: service_request1, organization: organization1, status: 'draft', protocol_id: @protocol1.id)

        service_request2 = create(:service_request_without_validations, protocol: @protocol2)
                           create(:sub_service_request, service_request: service_request2, organization: organization2, status: 'draft', protocol_id: @protocol2.id)

        service_request3 = create(:service_request_without_validations, protocol: @protocol3)
                           create(:sub_service_request, service_request: service_request3, organization: organization3, status: 'draft', protocol_id: @protocol3.id)
      end

      it "should match against title case insensitively (lowercase)" do
        visit_protocols_index_page
        wait_for_javascript_to_finish

        expect(@page.search_results).to have_protocols(count: 3)

        @page.filter_protocols.select_search(@page, "Short/Long Title", "title")
        @page.filter_protocols.apply_filter_button.click()
        wait_for_javascript_to_finish

        expect(@page.search_results).to have_protocols(text: "Protocol1")
        expect(@page.search_results).to have_protocols(text: "Protocol2")
        expect(@page.search_results).to have_no_protocols(text: "Protocol3")
      end

      it "should match against whole short title case insensitively (uppercase)" do
        visit_protocols_index_page
        wait_for_javascript_to_finish

        expect(@page.search_results).to have_protocols(count: 3)

        @page.filter_protocols.select_search(@page, "Short/Long Title", "Protocol1")
        @page.filter_protocols.apply_filter_button.click
        wait_for_javascript_to_finish

        expect(@page.search_results).to have_protocols(text: "Protocol1")
        expect(@page.search_results).to have_no_protocols(text: "Protocol2")
        expect(@page.search_results).to have_no_protocols(text: "Protocol3")
      end

      it "should match against partial short title case insensitively (uppercase)" do
        visit_protocols_index_page
        wait_for_javascript_to_finish

        expect(@page.search_results).to have_protocols(count: 3)

        @page.filter_protocols.select_search(@page, "Short/Long Title", "Protocol")
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

        expect(@page.search_results).to have_protocols(count: 3)

        @page.filter_protocols.select_search(@page, "Short/Long Title", "%")
        @page.filter_protocols.apply_filter_button.click()
        wait_for_javascript_to_finish

        expect(@page.search_results).to have_protocols(text: "title %")
        expect(@page.search_results).to have_no_protocols(text: "_Title")
        expect(@page.search_results).to have_protocols(text: "a%a")
      end
    end

    context "Protocol ID search" do
      before :each do
        organization1 = create(:organization)
        organization2 = create(:organization)
        organization3 = create(:organization)
        create(:service_provider, organization: organization1, identity: user)
        create(:service_provider, organization: organization2, identity: user)
        create(:service_provider, organization: organization3, identity: user)

        @protocol1 = create_protocol(archived: false, title: "titlex", short_title: "Protocol1")
        create(:project_role, identity: user, role: "very-important", project_rights: "to-party", protocol: @protocol1)

        @protocol2 = create_protocol(archived: false, title: "xTitle", short_title: "Protocol2")
        create(:project_role, identity: user, role: "very-important", project_rights: "to-party", protocol: @protocol2)

        @protocol3 = create_protocol(archived: false, title: "aaa", short_title: "Protocol3")
        create(:project_role, identity: user, role: "very-important", project_rights: "to-party", protocol: @protocol3)

        service_request1 = create(:service_request_without_validations, protocol: @protocol1)
                           create(:sub_service_request, service_request: service_request1, organization: organization1, status: 'draft', protocol_id: @protocol1.id)

        service_request2 = create(:service_request_without_validations, protocol: @protocol2)
                           create(:sub_service_request, service_request: service_request2, organization: organization2, status: 'draft', protocol_id: @protocol2.id)

        service_request3 = create(:service_request_without_validations, protocol: @protocol3)
                           create(:sub_service_request, service_request: service_request3, organization: organization3, status: 'draft', protocol_id: @protocol3.id)
      end

      it "should match against id" do
        visit_protocols_index_page
        wait_for_javascript_to_finish

        expect(@page.search_results).to have_protocols(count: 3)

        @page.filter_protocols.select_search(@page, "Protocol ID", @protocol1.id.to_s)
        @page.filter_protocols.apply_filter_button.click
        wait_for_javascript_to_finish

        expect(@page.search_results).to have_protocols(count: 1)
        expect(@page.search_results).to have_protocols(text: "Protocol1")
      end
    end

    context 'Authorized User Search' do
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

        @protocol3 = create_protocol(archived: false, short_title: "Protocol3")
        create(:project_role, identity: user2, role: "very-important", project_rights: "to-party", protocol: @protocol3)

        service_request1 = create(:service_request_without_validations, protocol: @protocol1)
                           create(:sub_service_request, service_request: service_request1, organization: organization1, status: 'draft', protocol_id: @protocol1.id)

        service_request2 = create(:service_request_without_validations, protocol: @protocol2)
                           create(:sub_service_request, service_request: service_request2, organization: organization2, status: 'draft', protocol_id: @protocol2.id)

        service_request3 = create(:service_request_without_validations, protocol: @protocol3)
                           create(:sub_service_request, service_request: service_request3, organization: organization3, status: 'draft', protocol_id: @protocol3.id)
      end

      it "should match against associated users first name case insensitively (lowercase)" do
        visit_protocols_index_page
        wait_for_javascript_to_finish

        expect(@page.search_results).to have_protocols(count: 3)

        @page.filter_protocols.select_search(@page, "Authorized User", "james")
        @page.filter_protocols.apply_filter_button.click()
        wait_for_javascript_to_finish

        expect(@page.search_results).to have_no_protocols(text: "Protocol1")
        expect(@page.search_results).to have_no_protocols(text: "Protocol2")
        expect(@page.search_results).to have_protocols(text: "Protocol3")
      end

      it "should match against associated users last name case insensitively (uppercase)" do
        visit_protocols_index_page
        wait_for_javascript_to_finish

        expect(@page.search_results).to have_protocols(count: 3)

        @page.filter_protocols.select_search(@page, "Authorized User", "Doop")
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

        @page.filter_protocols.select_search(@page, "Authorized User", "Hedwig")
        @page.filter_protocols.apply_filter_button.click()
        wait_for_javascript_to_finish

        expect(@page.search_results).to have_no_protocols(text: "Protocol1")
        expect(@page.search_results).to have_no_protocols(text: "Protocol2")
        expect(@page.search_results).to have_no_protocols(text: "Protocol3")
      end
    end

    context 'PI Search' do
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

        @protocol3 = create_protocol(archived: false, short_title: "Protocol3")
        create(:project_role, identity: user, role: "very-important", project_rights: "to-party", protocol: @protocol3)

        service_request1 = create(:service_request_without_validations, protocol: @protocol1)
                           create(:sub_service_request, service_request: service_request1, organization: organization1, status: 'draft', protocol_id: @protocol1.id)

        service_request2 = create(:service_request_without_validations, protocol: @protocol2)
                           create(:sub_service_request, service_request: service_request2, organization: organization2, status: 'draft', protocol_id: @protocol2.id)

        service_request3 = create(:service_request_without_validations, protocol: @protocol3)
                           create(:sub_service_request, service_request: service_request3, organization: organization3, status: 'draft', protocol_id: @protocol3.id)
      end

      it "should match against pi first name case insensitively (lowercase)" do
        visit_protocols_index_page
        wait_for_javascript_to_finish

        expect(@page.search_results).to have_protocols(count: 3)

        @page.filter_protocols.select_search(@page, "PI", @protocol3.principal_investigators.first.first_name.downcase)
        @page.filter_protocols.apply_filter_button.click()
        wait_for_javascript_to_finish

        expect(@page.search_results).to have_no_protocols(text: "Protocol1")
        expect(@page.search_results).to have_no_protocols(text: "Protocol2")
        expect(@page.search_results).to have_protocols(text: "Protocol3")
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

        @protocol1 = create_protocol(archived: false, short_title: "Protocol1")
        create(:project_role, identity: user, role: "very-important", project_rights: "to-party", protocol: @protocol1)

        @protocol2 = create_protocol(archived: false, short_title: "Protocol2")
        create(:project_role, identity: user, role: "very-important", project_rights: "to-party", protocol: @protocol2)

        @protocol3 = create_protocol(archived: false, short_title: "Protocol3")
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

        @protocol1 = create_protocol(archived: false, short_title: "Protocol1")
        create(:project_role, identity: user, role: "very-important", project_rights: "to-party", protocol: @protocol1)

        @protocol2 = create_protocol(archived: false, short_title: "Protocol2")
        create(:project_role, identity: user, role: "very-important", project_rights: "to-party", protocol: @protocol2)

        @protocol3 = create_protocol(archived: false, short_title: "Protocol3")
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

  describe "Owner Dropdown" do
    it 'should only display protocols with sub service requests that have the specified service provider' do
      person = create(:identity, first_name: "Wilson", last_name: "Fisk")
      organization1 = create(:organization, name: 'MagikarpLLC')
      organization2 = create(:organization, name: 'Union Allied')
      create(:service_provider, organization: organization1, identity: user)
      create(:service_provider, organization: organization2, identity: user)
      create(:service_provider, organization: organization2, identity: person)
      protocol1 = create(:protocol_without_validations, type: 'Study', archived: false, short_title: 'Magikarp Protocol', primary_pi: user)
      protocol2 = create(:protocol_without_validations, type: 'Study', archived: false, short_title: 'Construction', primary_pi: user)
      service_request1 = create(:service_request_without_validations, protocol: protocol1)
      service_request2 = create(:service_request_without_validations, protocol: protocol2)
      ssr1 = create(:sub_service_request, service_request: service_request1, organization: organization1, status: 'draft', protocol_id: protocol1.id)
      ssr2 = create(:sub_service_request, service_request: service_request2, organization: organization2, status: 'draft', protocol_id: protocol2.id, owner: person)

      visit_protocols_index_page
      wait_for_javascript_to_finish

      @page.filter_protocols.select_owner("Fisk, Wilson")
      @page.filter_protocols.apply_filter_button.click
      wait_for_javascript_to_finish

      expect(@page.search_results).to have_protocols(text: "Construction")
      expect(@page.search_results).to have_no_protocols(text: "Magikarp Protocol")
    end
  end

  describe "My Admin Protocols" do
    let(:organization) { create(:organization, admin: user, name: "MegaCorp") }

    context "user checks My Admin Protocols and clicks the filter button" do
      it "should only display Protocols contain SSRs belonging to users authorized Organizations" do
        # protocol belonging to user's admin organization
        protocol1 = create_protocol(archived: false, short_title: "Protocol1", organization: organization)
        create(:project_role, identity: user, role: "very-important", project_rights: "to-party", protocol: protocol1)

        # protocol not belonging to user's admin organization
        protocol2 = create_protocol(archived: false, short_title: "Protocol2")
        create(:project_role, identity: user, role: "very-important", project_rights: "to-party", protocol: protocol2)

        visit_protocols_index_page
        wait_for_javascript_to_finish

        expect(@page.search_results).to have_protocols(text: "Protocol1")
        expect(@page.search_results).to have_no_protocols(text: "Protocol2")
      end
    end
  end

  describe "core dropdown" do
    let(:mega_corp_organization) { create(:organization, admin: user, name: "MegaCorp", type: 'Institution') }
    let(:trump_organization) { create(:organization, admin: user, name: "TrumpPenitentiaries", type: 'Institution') }
    let(:some_organization) { create(:organization, admin: user, name: "SomeLLC", type: 'Institution') }

    context "user selects multiple admin protocols by name and clicks the Filter button" do
      it "should restrict listing to Protocols with SSRs belonging to those Organizations" do
        mega_corp_protocol = create_protocol(archived: false, short_title: "MegaCorpProtocol", organization: mega_corp_organization)
        mega_corp_protocol.project_roles.create(identity_id: user.id, role: "very-important", project_rights: "to-party")

        trump_protocol = create_protocol(archived: false, short_title: "TrumpProtocol", organization: trump_organization)
        trump_protocol.project_roles.create(identity_id: user.id, role: "very-important", project_rights: "to-party")

        llc_protocol = create_protocol(archived: false, short_title: "LLCProtocol", organization: some_organization)
        llc_protocol.project_roles.create(identity_id: user.id, role: "very-important", project_rights: "to-party")

        visit_protocols_index_page
        wait_for_javascript_to_finish

        @page.filter_protocols.select_core("MegaCorp", "SomeLLC")
        @page.filter_protocols.apply_filter_button.click
        wait_for_javascript_to_finish

        expect(@page.search_results).to have_protocols(text: "MegaCorpProtocol")
        expect(@page.search_results).to have_no_protocols(text: "TrumpProtocol")
        expect(@page.search_results).to have_no_protocols(text: "Protocol2")
      end
    end
  end

  # Creates a protocol using FactoryGirl, optionally with a SubServiceRequest
  #
  # @param [Hash] opts Options for creating the Protocol, all but :status and :organization
  #   being passed directly to FactoryGirl.create. If any of those two options are present,
  #   then a SubServiceRequest is created for the Protocol, via a ServiceRequest.
  # @option opts [String] :status Status for SubServiceRequest
  # @option opts [Organization] :organization Organization for SubServiceRequest.
  # @return [Protocol]
  def create_protocol(opts = {})
    # parameters for SubServiceRequest
    # if they exist, we'll create one
    status = opts.delete(:status)
    organization = opts.delete(:organization)

    protocol = create(:project_without_validations, opts.merge(primary_pi: create(:identity)))

    if status.present? || organization.present?
      service_request = create(:service_request_without_validations,
        protocol: protocol)
      create(:sub_service_request,
        status: status || "approved",
        organization: organization || create(:organization),
        service_request: service_request,
        protocol_id: protocol.id)
    end

    protocol
  end
end
