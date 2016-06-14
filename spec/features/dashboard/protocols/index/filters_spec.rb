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

      expect(@page.search_results).to have_protocols
    end
  end

  describe "save" do
    context "user clicks save" do
      it "should allow user to save filter" do
        visit_protocols_index_page
        expect do
          @page.instance_exec do
            filter_protocols.archived_checkbox.click
            filter_protocols.select_status("Active", "Complete")
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
        @page.recently_saved_filters.filters.first.click

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
        archived_protocol = create_protocol(archived: true, short_title: "ArchivedProject")
        archived_protocol.project_roles.create(identity_id: user.id, role: "very-important", project_rights: "to-party")
        unarchived_protocol = create_protocol(archived: false, short_title: "UnarchivedProject")
        unarchived_protocol.project_roles.create(identity_id: user.id, role: "very-important", project_rights: "to-party")

        visit_protocols_index_page
        @page.filter_protocols.archived_checkbox.set(true)
        @page.filter_protocols.apply_filter_button.click

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
        @page.filter_protocols.select_status("Approved", "Active")
        @page.filter_protocols.apply_filter_button.click

        expect(@page.search_results).to have_protocols(count: 2)
        expect(@page.search_results).to have_no_protocols(text: "NoSubServiceRequests")
        expect(@page.search_results).to have_protocols(text: "ApprovedProtocol")
        expect(@page.search_results).to have_protocols(text: "ActiveProtocol")
        expect(@page.search_results).to have_no_protocols(text: "DraftProtocol")
      end
    end
  end

  describe "search" do
    it "should match against short title case insensitively" do
      titlexProtocol = create_protocol(archived: false, short_title: "titlex")
      titlexProtocol.project_roles.create(identity_id: user.id, role: "very-important", project_rights: "to-party")
      xTitleProtocol = create_protocol(archived: false, short_title: "xTitle")
      xTitleProtocol.project_roles.create(identity_id: user.id, role: "very-important", project_rights: "to-party")
      aaaProtocol = create_protocol(archived: false, short_title: "aaa")
      aaaProtocol.project_roles.create(identity_id: user.id, role: "very-important", project_rights: "to-party")

      visit_protocols_index_page
      expect(@page.search_results).to have_protocols(count: 3)
      @page.filter_protocols.search_field.set("title")
      @page.filter_protocols.apply_filter_button.click

      expect(@page.search_results).to have_protocols(text: "titlex")
      expect(@page.search_results).to have_protocols(text: "xTitle")
      expect(@page.search_results).to have_no_protocols(text: "aaa")
    end

    it "should match against title case insensitively" do
      titlexProtocol = create_protocol(archived: false, title: "titlex", short_title: "Protocol1")
      titlexProtocol.project_roles.create(identity_id: user.id, role: "very-important", project_rights: "to-party")
      xTitleProtocol = create_protocol(archived: false, title: "xTitle", short_title: "Protocol2")
      xTitleProtocol.project_roles.create(identity_id: user.id, role: "very-important", project_rights: "to-party")
      aaaProtocol = create_protocol(archived: false, title: "aaa", short_title: "Protocol3")
      aaaProtocol.project_roles.create(identity_id: user.id, role: "very-important", project_rights: "to-party")

      visit_protocols_index_page
      @page.filter_protocols.search_field.set("title")
      @page.filter_protocols.apply_filter_button.click

      expect(@page.search_results).to have_protocols(text: "Protocol1")
      expect(@page.search_results).to have_protocols(text: "Protocol2")
      expect(@page.search_results).to have_no_protocols(text: "Protocol3")
    end

    it "should match against id" do
      protocol1 = create_protocol(archived: false, short_title: "Protocol1")
      protocol1.project_roles.create(identity_id: user.id, role: "very-important", project_rights: "to-party")
      protocol2 = create_protocol(archived: false, short_title: "Protocol2")
      protocol2.project_roles.create(identity_id: user.id, role: "very-important", project_rights: "to-party")
      protocol3 = create_protocol(archived: false, short_title: "Protocol3")
      protocol3.project_roles.create(identity_id: user.id, role: "very-important", project_rights: "to-party")

      visit_protocols_index_page
      @page.filter_protocols.search_field.set(protocol1.id.to_s)
      @page.filter_protocols.apply_filter_button.click

      expect(@page.search_results).to have_protocols(count: 1)
      expect(@page.search_results).to have_protocols(text: "Protocol1")
    end

    it "should match against associated users first name case insensitively (lowercase)" do
      protocol1 = create_protocol(archived: false, short_title: "Protocol1")
      create(:project_role, identity: user, role: "very-important", project_rights: "to-party", protocol: protocol1)
      protocol2 = create_protocol(archived: false, short_title: "Protocol2")
      create(:project_role, identity: user, role: "very-important", project_rights: "to-party", protocol: protocol2)
      protocol3 = create_protocol(archived: false, short_title: "Protocol3")
      create(:project_role, identity: user, role: "very-important", project_rights: "to-party", protocol: protocol3)

      visit_protocols_index_page
      @page.filter_protocols.search_field.set("john")
      @page.filter_protocols.apply_filter_button.click()
      
      expect(@page.search_results).to have_protocols(text: "Protocol1")
      expect(@page.search_results).to have_protocols(text: "Protocol2")
      expect(@page.search_results).to have_protocols(text: "Protocol3")
    end

    it "should match against associated users last name case insensitively (uppercase)" do
      protocol1 = create_protocol(archived: false, short_title: "Protocol1")
      create(:project_role, identity: user, role: "very-important", project_rights: "to-party", protocol: protocol1)
      protocol2 = create_protocol(archived: false, short_title: "Protocol2")
      create(:project_role, identity: user, role: "very-important", project_rights: "to-party", protocol: protocol2)
      protocol3 = create_protocol(archived: false, short_title: "Protocol3")
      create(:project_role, identity: user, role: "very-important", project_rights: "to-party", protocol: protocol3)

      visit_protocols_index_page
      @page.filter_protocols.search_field.set("John")
      @page.filter_protocols.apply_filter_button.click()

      expect(@page.search_results).to have_protocols(text: "Protocol1")
      expect(@page.search_results).to have_protocols(text: "Protocol2")
      expect(@page.search_results).to have_protocols(text: "Protocol3")
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
        @page.filter_protocols.select_core("MegaCorp", "SomeLLC")
        @page.filter_protocols.apply_filter_button.click

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
        service_request: service_request)
    end

    protocol
  end
end
