require "rails_helper"

RSpec.describe "filters", js: :true do
  let!(:user) do
    create(:identity,
           last_name: "Claws",
           first_name: "Santa",
           ldap_uid: "santa",
           institution: "medical_university_of_south_carolina",
           college: "college_of_medicine",
           department: "other",
           email: "santa@musc.edu",
           credentials: "ba",
           catalog_overlord: true,
           password: "p4ssword",
           password_confirmation: "p4ssword",
           approved: true)
  end

  fake_login_for_each_test("santa")

  def visit_protocols_index_page
    @page = Dashboard::Protocols::IndexPage.new
    @page.load
  end

  describe "default" do
    it "should display unarchived Protocols with SubServiceRequests of any status for which the user has a ProjectRole without 'none' rights" do
      protocol = create(:unarchived_project_without_validations,
                 primary_pi: create(:identity),
                 project_role: { identity_id: user.id, role: "very-important", project_rights: "not-none" })
      service_request = create(:service_request_without_validations, protocol: protocol)
      create(:sub_service_request_with_organization,
             service_request: service_request,
             status: "single-ready-to-mingle")

      visit_protocols_index_page

      expect(@page.search_results).to have_protocols
    end
  end

  describe "save" do
    context "user clicks save" do
      it "should allow user to save filter" do
        create(:unarchived_project_without_validations,
               primary_pi: create(:identity),
               title: "My Awesome Protocol")

        visit_protocols_index_page
        @page.instance_exec do
          filter_protocols.archived_checkbox.click
          filter_protocols.save_link.click
          wait_for_filter_form_modal
          filter_form_modal.name_field.set("MyFilter")
          filter_form_modal.save_button.click
        end

        expect(@page.recently_saved_filters).to have_filters(text: "MyFilter")
        expect(ProtocolFilter.count).to eq(1)
      end
    end
  end

  describe "recently saved filters" do
    context "user has saved filters and clicks a saved filter name" do
      it "should apply that filter" do
        create(:archived_project_without_validations,
               primary_pi: create(:identity),
               project_role: { identity_id: user.id, role: "very-important", project_rights: "to-party" })

        f = ProtocolFilter.create(search_name: "MyFilter",
                                  show_archived: true,
                                  for_admin: false,
                                  for_identity_id: true,
                                  search_query: "",
                                  with_status: "")
        f.identity = user
        f.save!

        visit_protocols_index_page
        @page.recently_saved_filters.filters.first.click

        expect(@page.search_results).to have_protocols
      end
    end
  end

  describe "reset" do
    it "should remove all filters" do
      create(:archived_project_without_validations,
               primary_pi: create(:identity),
               short_title: "ArchivedProject",
               project_role: { identity_id: user.id, project_rights: "to-party", role: "very-important" })
      create(:unarchived_project_without_validations,
             primary_pi: create(:identity),
             short_title: "UnarchivedProject",
             project_role: { identity_id: user.id, project_rights: "to-party", role: "very-important" })

      visit_protocols_index_page
      @page.filter_protocols.archived_checkbox.click
      @page.filter_protocols.apply_filter_button.click
      @page.filter_protocols.reset_link.click

      expect(@page.search_results).to have_protocols(text: "UnarchivedProject")
      expect(@page.search_results).to have_no_protocols(text: "ArchivedProject")
    end
  end

  describe "archived checkbox" do
    context "user checks archived checkbox and clicks filter button" do
      it "should only show archived protocols" do
        create(:archived_project_without_validations,
               primary_pi: create(:identity),
               short_title: "ArchivedProject",
               project_role: { identity_id: user.id, project_rights: "to-party", role: "very-important" })
        create(:unarchived_project_without_validations,
               primary_pi: create(:identity),
               short_title: "UnarchivedProject",
               project_role: { identity_id: user.id, project_rights: "to-party", role: "very-important" })

        visit_protocols_index_page
        @page.filter_protocols.archived_checkbox.set(true)
        @page.filter_protocols.apply_filter_button.click

        expect(@page.search_results).to have_protocols(text: "ArchivedProject")
        expect(@page.search_results).to have_no_protocols(text: "UnarchivedProject")
      end
    end
  end

  describe "status dropdown" do
    context "user selects a status from dropdown and clicks the filter button" do
      it "should display only Protocols that have a SubServiceRequest of that status" do
        # protocol with no SubServiceRequests
        create(:unarchived_project_without_validations,
               primary_pi: create(:identity),
               project_role: { identity_id: user.id, project_rights: "to-party", role: "very-important" })

        # protocol with one SSR of status approved
        protocol_only_approved = create(:unarchived_project_without_validations,
                                        primary_pi: create(:identity),
                                        short_title: "OneApproved",
                                        project_role: { identity_id: user.id, project_rights: "to-party", role: "very-important" })
        service_request_only_approved = create(:service_request_without_validations,
                                               protocol: protocol_only_approved)
        create(:sub_service_request_with_organization,
               service_request: service_request_only_approved,
               status: "approved")

        # protocol with one SSR of status approved and another
        # SSR of another status
        protocol_one_draft_one_approved = create(:unarchived_project_without_validations,
                                                 primary_pi: create(:identity),
                                                 short_title: "OneDraft",
                                                 project_role: { identity_id: user.id, project_rights: "to-party", role: "very-important" })
        service_request_one_draft_one_approved = create(:service_request_without_validations,
                                                        protocol: protocol_one_draft_one_approved)
        create(:sub_service_request_with_organization,
               service_request: service_request_one_draft_one_approved,
               status: "approved")
        create(:sub_service_request_with_organization,
               service_request: service_request_one_draft_one_approved,
               status: "draft")

        # protocol with a SSR not of status approved
        protocol_only_draft = create(:unarchived_project_without_validations,
                                     primary_pi: create(:identity),
                                     project_role: { identity_id: user.id, project_rights: "to-party", role: "very-important" })
        service_request_only_draft = create(:service_request_without_validations,
                                            protocol: protocol_only_draft)
        create(:sub_service_request_with_organization,
               service_request: service_request_only_draft,
               status: "draft")

        visit_protocols_index_page
        @page.filter_protocols.select_status("approved")
        @page.filter_protocols.apply_filter_button.click

        expect(@page.search_results).to have_protocols(count: 2)
        expect(@page.search_results).to have_protocols(text: "OneApproved")
        expect(@page.search_results).to have_protocols(text: "OneDraft")
      end
    end
  end

  describe "search" do
    it "should match against short title case insensitively" do
      create(:unarchived_project_without_validations,
             primary_pi: create(:identity),
             short_title: "titlex",
             project_role: { identity_id: user.id, project_rights: "to-party", role: "very-important" })
      create(:unarchived_project_without_validations,
             primary_pi: create(:identity),
             short_title: "xTitle",
             project_role: { identity_id: user.id, project_rights: "to-party", role: "very-important" })
      create(:unarchived_project_without_validations,
             primary_pi: create(:identity),
             short_title: "aaa",
             project_role: { identity_id: user.id, project_rights: "to-party", role: "very-important" })

      visit_protocols_index_page
      expect(@page.search_results).to have_protocols(count: 3)
      @page.filter_protocols.search_field.set("title")
      @page.filter_protocols.apply_filter_button.click

      expect(@page.search_results).to have_protocols(count: 2)
      expect(@page.search_results).to have_no_protocols(text: "aaa")
    end

    it "should match against title case insensitively" do
      create(:unarchived_project_without_validations,
             primary_pi: create(:identity),
             short_title: "Protocol1",
             title: "titlex",
             project_role: { identity_id: user.id, project_rights: "to-party", role: "very-important" })
      create(:unarchived_project_without_validations,
             primary_pi: create(:identity),
             short_title: "Protocol2",
             title: "xTitle",
             project_role: { identity_id: user.id, project_rights: "to-party", role: "very-important" })
      create(:unarchived_project_without_validations,
             primary_pi: create(:identity),
             short_title: "Protocol3",
             title: "aaa",
             project_role: { identity_id: user.id, project_rights: "to-party", role: "very-important" })

      visit_protocols_index_page
      @page.filter_protocols.search_field.set("title")
      @page.filter_protocols.apply_filter_button.click

      expect(@page.search_results).to have_protocols(count: 2)
      expect(@page.search_results).to have_no_protocols(text: "Protocol3")
    end

    it "should match against id" do
      protocol1 = create(:unarchived_project_without_validations,
                         primary_pi: create(:identity),
                         short_title: "Protocol1",
                         project_role: { identity_id: user.id, project_rights: "to-party", role: "very-important" })
      create(:unarchived_project_without_validations,
             primary_pi: create(:identity),
             short_title: "Protocol2",
             project_role: { identity_id: user.id, project_rights: "to-party", role: "very-important" })
      create(:unarchived_project_without_validations,
             primary_pi: create(:identity),
             short_title: "Protocol3",
             project_role: { identity_id: user.id, project_rights: "to-party", role: "very-important" })

      visit_protocols_index_page
      @page.filter_protocols.search_field.set(protocol1.id.to_s)
      @page.filter_protocols.apply_filter_button.click

      expect(@page.search_results).to have_protocols(count: 1)
      expect(@page.search_results).to have_protocols(text: "Protocol1")
    end

    it "should match against associated users first name case insensitively" do
      protocol1 = create(:unarchived_project_without_validations,
                         primary_pi: create(:identity),
                         short_title: "Protocol1",
                         project_role: { identity_id: user.id, project_rights: "to-party", role: "very-important" })
      create(:project_role, protocol: protocol1, identity: create(:identity, first_name: "name1"))
      protocol2 = create(:unarchived_project_without_validations,
                         primary_pi: create(:identity),
                         short_title: "Protocol2",
                         project_role: { identity_id: user.id, project_rights: "to-party", role: "very-important" })
      create(:project_role, protocol: protocol2, identity: create(:identity, first_name: "Name1"))
      protocol3 = create(:unarchived_project_without_validations,
                         primary_pi: create(:identity),
                         short_title: "Protocol3",
                         project_role: { identity_id: user.id, project_rights: "to-party", role: "very-important" })
      create(:project_role, protocol: protocol3, identity: create(:identity, first_name: "name3"))

      visit_protocols_index_page
      @page.filter_protocols.search_field.set("name1")
      @page.filter_protocols.apply_filter_button.click

      expect(@page.search_results).to have_protocols(count: 2)
      expect(@page.search_results).to have_protocols(text: "Protocol1")
      expect(@page.search_results).to have_protocols(text: "Protocol2")
    end

    it "should match against associated users last name case insensitively" do
      protocol1 = create(:unarchived_project_without_validations,
                         primary_pi: create(:identity),
                         short_title: "Protocol1",
                         project_role: { identity_id: user.id, project_rights: "to-party", role: "very-important" })
      create(:project_role, protocol: protocol1, identity: create(:identity, last_name: "name1"))
      protocol2 = create(:unarchived_project_without_validations,
                         primary_pi: create(:identity),
                         short_title: "Protocol2",
                         project_role: { identity_id: user.id, project_rights: "to-party", role: "very-important" })
      create(:project_role, protocol: protocol2, identity: create(:identity, last_name: "Name1"))
      protocol3 = create(:unarchived_project_without_validations,
                         primary_pi: create(:identity),
                         short_title: "Protocol3",
                         project_role: { identity_id: user.id, project_rights: "to-party", role: "very-important" })
      create(:project_role, protocol: protocol3, identity: create(:identity, last_name: "name3"))

      visit_protocols_index_page
      @page.filter_protocols.search_field.set("name1")
      @page.filter_protocols.apply_filter_button.click

      expect(@page.search_results).to have_protocols(count: 2)
      expect(@page.search_results).to have_protocols(text: "Protocol1")
      expect(@page.search_results).to have_protocols(text: "Protocol2")
    end
  end

  describe "my protocols" do
    context "user is a service provider and a superuser for an Organization" do
      let!(:organization) { create(:organization, admin: user) }

      context "user unchecks My Protocols and clicks the filter button" do
        it "should display all Protocols" do
          create(:unarchived_project_without_validations, primary_pi: create(:identity),
                 short_title: "Protocol1",
                 project_role: { identity_id: user.id, project_rights: "to-party", role: "very-important" })
          create(:unarchived_project_without_validations, primary_pi: create(:identity), short_title: "Protocol2")

          visit_protocols_index_page
          @page.filter_protocols.my_protocols_checkbox.click
          @page.filter_protocols.apply_filter_button.click

          expect(@page.search_results).to have_protocols(count: 2)
        end
      end
    end
  end

  describe "my admin organizations" do
    let(:organization) { create(:organization, admin: user, name: "MegaCorp") }

    context "user checks My Admin Organizations and clicks the filter button" do
      it "should only display Protocols contain SSRs belonging to users authorized Organizations" do
        protocol1 = create(:unarchived_project_without_validations,
                           primary_pi: create(:identity),
                           short_title: "Protocol1",
                           project_role: { identity_id: user.id, project_rights: "to-party", role: "very-important" })
        create(:service_request_without_validations, protocol: protocol1, organizations: [organization])

        protocol2 = create(:unarchived_project_without_validations,
                           primary_pi: create(:identity),
                           short_title: "Protocol2",
                           project_role: { identity_id: user.id, project_rights: "to-party", role: "very-important" })
        create(:service_request_without_validations, protocol: protocol2, organizations: [create(:organization)])

        visit_protocols_index_page
        @page.filter_protocols.my_admin_organizations_checkbox.click
        @page.filter_protocols.apply_filter_button.click

        expect(@page.search_results).to have_protocols(text: "Protocol1")
        expect(@page.search_results).to have_no_protocols(text: "Protocol2")
      end
    end
  end

  describe "core dropdown" do
    let(:organization) { create(:organization, admin: user, name: "MegaCorp") }

    context "user selects an Organization by name and clicks the Filter button" do
      it "should restrict listing to Protocols with SSRs belonging to that Organization" do
        protocol1 = create(:unarchived_project_without_validations,
                           primary_pi: create(:identity),
                           short_title: "Protocol1",
                           project_role: { identity_id: user.id, project_rights: "to-party"})
        create(:service_request_without_validations, protocol: protocol1, organizations: [organization])

        protocol2 = create(:unarchived_project_without_validations,
                           primary_pi: create(:identity),
                           short_title: "Protocol2",
                           project_role: { identity_id: user.id, project_rights: "to-party", role: "very-important" })
        create(:service_request_without_validations, protocol: protocol2, organizations: [create(:organization)])

        visit_protocols_index_page
        @page.filter_protocols.select_core(organization.name)
        @page.filter_protocols.apply_filter_button.click

        expect(@page.search_results).to have_protocols(text: "Protocol1")
        expect(@page.search_results).to have_no_protocols(text: "Protocol2")
      end
    end
  end
end
