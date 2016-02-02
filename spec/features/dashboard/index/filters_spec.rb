require 'rails_helper'

RSpec.describe 'filters', js: :true do
  let_there_be_lane
  fake_login_for_each_test

  def visit_protocols_index_page
    @page = Dashboard::Protocols::IndexPage.new
    @page.load
    wait_for_javascript_to_finish
  end

  describe 'archived checkbox' do
    describe 'defaults' do
      it 'should not display archived Protocols' do
        create(:protocol_federally_funded, :without_validations, primary_pi: jug2, type: 'Project', archived: true)
        visit_protocols_index_page
        expect(@page).to have_no_protocols
      end

      it 'should not be checked' do
        visit_protocols_index_page
        expect(@page.filters.archived_checkbox).to_not be_checked
      end
    end

    context 'user checks archived checkbox and clicks filter button' do
      it 'should only show archived protocols' do
        archived_protocol = create(:protocol_federally_funded, :without_validations, primary_pi: jug2, type: 'Project', archived: true)
        create(:protocol_federally_funded, :without_validations, primary_pi: jug2, type: 'Project', archived: false)
        visit_protocols_index_page
        @page.filters.archived_checkbox.set(true)
        @page.filters.apply_filter_button.click
        wait_for_javascript_to_finish
        expect(@page.displayed_protocol_ids).to eq [archived_protocol.id]
      end
    end

    context 'user unchecks previously checked checkbox and clicks filter button' do
      it 'should only show unarchived protocols' do
        create(:protocol_federally_funded, :without_validations, primary_pi: jug2, type: 'Project', archived: true)
        unarchived_protocol = create(:protocol_federally_funded, :without_validations, primary_pi: jug2, type: 'Project', archived: false)
        visit_protocols_index_page
        @page.filters.archived_checkbox.set(true)
        @page.filters.apply_filter_button.click
        expect(@page.filters.archived_checkbox).to be_checked
        @page.filters.archived_checkbox.set(true)
        @page.filters.apply_filter_button.click
        expect(@page.displayed_protocol_ids).to eq [unarchived_protocol.id]
      end
    end
  end

  describe 'status dropdown' do
    describe 'defaults' do
      it 'should display Protocols with SubServiceRequests of any status' do
        AVAILABLE_STATUSES.each do |status|
          p = create(:protocol_federally_funded, :without_validations, primary_pi: jug2, type: 'Project', archived: false)
          sr = create(:service_request_without_validations, protocol: p, service_requester: jug2)
          create(:sub_service_request, ssr_id: '0001', service_request: sr, organization: create(:organization), status: status)
        end

        visit_protocols_index_page
        expect(@page.protocols.size).to eq(AVAILABLE_STATUSES.length)
      end
    end

    context 'user selects a status from dropdown and clicks the filter button' do
      it 'should display only Protocols that have a SubServiceRequest of that status' do
        # protocol with no SubServiceRequests
        p1 = create(:protocol_federally_funded, :without_validations, primary_pi: jug2, type: 'Project', archived: false)

        # protocol with one SSR of status approved
        p2 = create(:protocol_federally_funded, :without_validations, primary_pi: jug2, type: 'Project', archived: false)
        sr = create(:service_request_without_validations, protocol: p2, service_requester: jug2)
        create(:sub_service_request, ssr_id: '0001', service_request: sr, organization: create(:organization), status: 'approved')

        # protocol with one SSR of status approved and another
        # SSR of another status
        p3 = create(:protocol_federally_funded, :without_validations, primary_pi: jug2, type: 'Project', archived: false)
        sr = create(:service_request_without_validations, protocol: p3, service_requester: jug2)
        create(:sub_service_request, ssr_id: '0001', service_request: sr, organization: create(:organization), status: 'approved')
        create(:sub_service_request, ssr_id: '0001', service_request: sr, organization: create(:organization), status: 'draft')

        # protocol with a SSR not of status approved
        p4 = create(:protocol_federally_funded, :without_validations, primary_pi: jug2, type: 'Project', archived: false)
        sr = create(:service_request_without_validations, protocol: p4, service_requester: jug2)
        create(:sub_service_request, ssr_id: '0001', service_request: sr, organization: create(:organization), status: 'draft')

        visit_protocols_index_page
        expect(@page.displayed_protocol_ids.sort).to eq [p1.id, p2.id, p3.id, p4.id]

        @page.filters.select_status('approved')
        @page.filters.apply_filter_button.click
        wait_for_javascript_to_finish
        expect(@page.displayed_protocol_ids.sort).to eq [p2.id, p3.id]
      end
    end
  end

  describe 'search' do
    it 'should match against short title case insensitively' do
      protocol1 = create(:protocol_federally_funded, :without_validations, primary_pi: jug2, type: 'Project', archived: false, short_title: 'titlex')
      protocol2 = create(:protocol_federally_funded, :without_validations, primary_pi: jug2, type: 'Project', archived: false, short_title: 'xTitle')
      create(:protocol_federally_funded, :without_validations, primary_pi: jug2, type: 'Project', archived: false, short_title: 'aaa')
      visit_protocols_index_page
      @page.filters.search_field.set('title')
      @page.filters.apply_filter_button.click
      wait_for_javascript_to_finish
      expect(@page.displayed_protocol_ids.sort).to eq [protocol1.id, protocol2.id]
    end

    it 'should match against title case insensitively' do
      protocol1 = create(:protocol_federally_funded, :without_validations, primary_pi: jug2, type: 'Project', archived: false, title: 'titlex')
      protocol2 = create(:protocol_federally_funded, :without_validations, primary_pi: jug2, type: 'Project', archived: false, title: 'xTitle')
      create(:protocol_federally_funded, :without_validations, primary_pi: jug2, type: 'Project', archived: false, title: 'aaa')
      visit_protocols_index_page
      @page.filters.search_field.set('title')
      @page.filters.apply_filter_button.click
      wait_for_javascript_to_finish
      expect(@page.displayed_protocol_ids.sort).to eq [protocol1.id, protocol2.id]
    end

    it 'should match against id' do
      protocol1 = create(:protocol_federally_funded, :without_validations, primary_pi: jug2, type: 'Project', archived: false)
      create(:protocol_federally_funded, :without_validations, primary_pi: jug2, type: 'Project', archived: false)
      create(:protocol_federally_funded, :without_validations, primary_pi: jug2, type: 'Project', archived: false)
      visit_protocols_index_page
      @page.filters.search_field.set(protocol1.id.to_s)
      @page.filters.apply_filter_button.click
      wait_for_javascript_to_finish
      expect(@page.displayed_protocol_ids.sort).to eq [protocol1.id]
    end

    it 'should match against associated users\' first name case insensitively' do
      protocol1 = create(:protocol_federally_funded, :without_validations, primary_pi: jug2, type: 'Project', archived: false)
      create(:project_role, protocol: protocol1, identity: create(:identity, first_name: 'name1'))
      protocol2 = create(:protocol_federally_funded, :without_validations, primary_pi: jug2, type: 'Project', archived: false)
      create(:project_role, protocol: protocol2, identity: create(:identity, first_name: 'Name1'))
      protocol3 = create(:protocol_federally_funded, :without_validations, primary_pi: jug2, type: 'Project', archived: false)
      create(:project_role, protocol: protocol3, identity: create(:identity, first_name: 'name3'))

      visit_protocols_index_page
      @page.filters.search_field.set('name1')
      @page.filters.apply_filter_button.click
      wait_for_javascript_to_finish
      expect(@page.displayed_protocol_ids.sort).to eq [protocol1.id, protocol2.id]
    end

    it 'should match against associated users\' last name case insensitively' do
      protocol1 = create(:protocol_federally_funded, :without_validations, primary_pi: jug2, type: 'Project', archived: false)
      create(:project_role, protocol: protocol1, identity: create(:identity, last_name: 'name1'))
      protocol2 = create(:protocol_federally_funded, :without_validations, primary_pi: jug2, type: 'Project', archived: false)
      create(:project_role, protocol: protocol2, identity: create(:identity, last_name: 'Name1'))
      protocol3 = create(:protocol_federally_funded, :without_validations, primary_pi: jug2, type: 'Project', archived: false)
      create(:project_role, protocol: protocol3, identity: create(:identity, last_name: 'name3'))

      visit_protocols_index_page
      @page.filters.search_field.set('name1')
      @page.filters.apply_filter_button.click
      wait_for_javascript_to_finish
      expect(@page.displayed_protocol_ids.sort).to eq [protocol1.id, protocol2.id]
    end
  end

  describe 'my protocols' do
    context 'user is a service provider and a superuser for an Organization' do
      let!(:organization) { create(:organization) }
      let!(:service_provider) { create(:service_provider, identity: jug2, organization: organization) }
      let!(:super_user) { create(:super_user, identity: jug2, organization: organization) }

      it 'should show the My Protocols checkbox' do
        visit_protocols_index_page
        expect(@page.filters).to have_my_protocols_checkbox
      end

      it 'should be checked' do
        visit_protocols_index_page
        expect(@page.filters.my_protocols_checkbox).to be_checked
      end

      context 'user unchecks My Protocols and clicks the filter button' do
        it 'should display all Protocols' do
          protocol1 = create(:protocol_federally_funded, :without_validations, primary_pi: create(:identity), type: 'Project', archived: false)
          protocol2 = create(:protocol_federally_funded, :without_validations, primary_pi: jug2, type: 'Project', archived: false)
          visit_protocols_index_page
          @page.filters.my_protocols_checkbox.click
          @page.filters.apply_filter_button.click
          wait_for_javascript_to_finish
          expect(@page.displayed_protocol_ids.sort).to eq [protocol1.id, protocol2.id]
        end
      end

      context 'user checks previously unchecked My Protocols and clicks the filter button' do
        it 'should not display Protocols for which user is not an associated user' do
          create(:protocol_federally_funded, :without_validations, primary_pi: create(:identity), type: 'Project', archived: false)
          visit_protocols_index_page
          expect(@page).to have_no_protocols
        end

        it 'should not display Protocols for which user has \'none\' rights' do
          protocol = create(:protocol_federally_funded, :without_validations, primary_pi: create(:identity), type: 'Project', archived: false)
          create(:project_role, identity: jug2, protocol: protocol, project_rights: 'none')
          visit_protocols_index_page
          expect(@page).to have_no_protocols
        end

        it 'should display unarchived Protocols for which the user has project rights other than \'none\'' do
          create(:protocol_federally_funded, :without_validations, primary_pi: jug2, type: 'Project', archived: false)
          visit_protocols_index_page
          expect(@page).to have_protocols
        end
      end
    end

    context 'user is not both a service provider and a superuser for any Organization' do
      it 'should not show the My Protocols checkbox' do
        visit_protocols_index_page
        expect(@page.filters).to have_no_my_protocols_checkbox
      end
    end

    describe 'defaults' do
      it 'should not display Protocols for which user is not an associated user' do
        create(:protocol_federally_funded, :without_validations, primary_pi: create(:identity), type: 'Project', archived: false)
        visit_protocols_index_page
        expect(@page).to have_no_protocols
      end

      it 'should not display Protocols for which user has \'none\' rights' do
        protocol = create(:protocol_federally_funded, :without_validations, primary_pi: create(:identity), type: 'Project', archived: false)
        create(:project_role, identity: jug2, protocol: protocol, project_rights: 'none')
        visit_protocols_index_page
        expect(@page).to have_no_protocols
      end

      it 'should display unarchived Protocols for which the user has project rights other than \'none\'' do
        create(:protocol_federally_funded, :without_validations, primary_pi: jug2, type: 'Project', archived: false)
        visit_protocols_index_page
        expect(@page).to have_protocols
      end
    end
  end

  describe 'my admin organizations' do
    describe 'defaults' do
      let!(:organization) { create(:organization) }
      let!(:service_provider) { create(:service_provider, identity: jug2, organization: organization) }
      let!(:super_user) { create(:super_user, identity: jug2, organization: organization) }

      it 'should not restrict listing to Protocols with SSR\'s in user\'s authorized Organizations' do
        p1 = create(:protocol_federally_funded, :without_validations, primary_pi: jug2, type: 'Project', archived: false)
        sr1 = create(:service_request_without_validations, protocol: p1, service_requester: jug2)
        create(:sub_service_request, ssr_id: '0001', service_request: sr1, organization: organization, status: 'approved')

        p2 = create(:protocol_federally_funded, :without_validations, primary_pi: jug2, type: 'Project', archived: false)
        sr2 = create(:service_request_without_validations, protocol: p2, service_requester: jug2)
        create(:sub_service_request, ssr_id: '0001', service_request: sr2, organization: create(:organization), status: 'approved')

        visit_protocols_index_page
        expect(@page.displayed_protocol_ids.sort).to eq [p1.id, p2.id]
      end

      it 'should not be checked' do
        visit_protocols_index_page
        expect(@page.filters.my_admin_organizations_checkbox).to_not be_checked
      end
    end

    context 'user a service provider and superuser for an Organization' do
      let!(:organization) { create(:organization) }
      let!(:service_provider) { create(:service_provider, identity: jug2, organization: organization) }
      let!(:super_user) { create(:super_user, identity: jug2, organization: organization) }

      it 'should show the My Admin Organizations checkbox' do
        visit_protocols_index_page
        expect(@page.filters).to have_my_admin_organizations_checkbox
      end
    end

    context 'user is not both a service provider and a superuser for any Organization' do
      it 'should not show the My Admin Organizations checkbox' do
        visit_protocols_index_page
        expect(@page.filters).to have_no_my_admin_organizations_checkbox
      end
    end
  end
end
