require 'rails_helper'

RSpec.describe 'filters', js: :true do
  let_there_be_lane
  fake_login_for_each_test

  def visit_protocols_index_page
    @page = Dashboard::Protocols::IndexPage.new
    @page.load
    wait_for_javascript_to_finish
  end

  shared_context 'authorized Organizations' do
    let!(:org1) { create(:organization, admin: jug2, name: 'Organization 1') }
    let!(:org2) { create(:organization, admin: jug2, name: 'Organization 2') }
  end

  describe 'save' do
    let!(:protocol) { create(:protocol_federally_funded, :without_validations, primary_pi: jug2, type: 'Project', archived: false, title: 'My Awesome Protocol') }
    before(:each) do
      visit_protocols_index_page
      # expect(@page).to have_css('td', text: 'My Awesome Protocol')
      @page.filter_protocols.archived_checkbox.click
    end

    context 'user clicks save' do
      before(:each) do
        @page.filter_protocols.save_link.click
      end

      it 'should present a modal asking for filter name' do
        expect(@page).to have_content('Choose a name for your search')
      end

      context 'user enters name and clicks save' do
        before(:each) do
          # fill_in 'Name', with: 'my filter'
          @page.filter_form_modal.name_field.set('my filter')
          @page.filter_form_modal.save_button.click
          wait_for_javascript_to_finish
        end

        it 'should display saved filter name under "Recently Saved Filters"' do
          expect(@page).to have_recently_saved_filters
          expect(@page.recently_saved_filters).to have_filters
          expect(@page).to have_protocols
        end
      end
    end
  end

  describe 'recently saved filters' do
    let!(:protocol) { create(:protocol_federally_funded, :without_validations, primary_pi: jug2, type: 'Project', archived: true) }

    context 'user has saved filters' do
      before(:each) do
        6.times do |n|
          f = ProtocolFilter.create(search_name: "Filter #{n}",
            show_archived: true,
            for_admin: false,
            for_identity_id: true,
            search_query: '',
            with_status: '')
          f.identity = jug2
          f.save!
        end
        visit_protocols_index_page
        expect(@page).to have_no_protocols
      end

      context 'user clicks a saved filter name' do
        it 'should apply that filter' do
          @page.recently_saved_filters.filters.first.click
          wait_for_javascript_to_finish
          expect(@page).to have_protocols
        end
      end
    end
  end

  describe 'reset' do
    it 'should remove all filters' do
      p1 = create(:protocol_federally_funded, :without_validations, primary_pi: jug2, type: 'Project', archived: true, title: 'abc')
      sr = create(:service_request_without_validations, protocol: p1, service_requester: jug2)
      create(:sub_service_request, ssr_id: '0001', service_request: sr, organization: create(:organization), status: 'draft')

      p2 = create(:protocol_federally_funded, :without_validations, primary_pi: jug2, type: 'Project', archived: false)
      visit_protocols_index_page

      filters = @page.filter_protocols
      filters.search_field.set('abc')
      filters.archived_checkbox.click
      filters.select_status('draft')
      filters.apply_filter_button.click
      wait_for_javascript_to_finish

      expect(@page.displayed_protocol_ids).to eq [p1.id]
      @page.filter_protocols.reset_link.click
      wait_for_javascript_to_finish
      expect(@page.displayed_protocol_ids.sort).to eq [p2.id]
    end
  end

  describe 'archived checkbox' do
    describe 'defaults' do
      it 'should not display archived Protocols' do
        create(:protocol_federally_funded, :without_validations, primary_pi: jug2, type: 'Project', archived: true)
        visit_protocols_index_page
        expect(@page).to have_no_protocols
        expect(@page.filter_protocols.archived_checkbox).to_not be_checked
      end
    end

    context 'user checks archived checkbox and clicks filter button' do
      it 'should only show archived protocols' do
        archived_protocol = create(:protocol_federally_funded, :without_validations, primary_pi: jug2, type: 'Project', archived: true)
        create(:protocol_federally_funded, :without_validations, primary_pi: jug2, type: 'Project', archived: false)
        visit_protocols_index_page
        @page.filter_protocols.archived_checkbox.set(true)
        @page.filter_protocols.apply_filter_button.click
        wait_for_javascript_to_finish
        expect(@page.displayed_protocol_ids).to eq [archived_protocol.id]
      end
    end

    context 'user unchecks previously checked checkbox and clicks filter button' do
      it 'should only show unarchived protocols' do
        create(:protocol_federally_funded, :without_validations, primary_pi: jug2, type: 'Project', archived: true)
        unarchived_protocol = create(:protocol_federally_funded, :without_validations, primary_pi: jug2, type: 'Project', archived: false)
        visit_protocols_index_page
        @page.filter_protocols.archived_checkbox.set(true)
        @page.filter_protocols.apply_filter_button.click
        expect(@page.filter_protocols.archived_checkbox).to be_checked
        @page.filter_protocols.archived_checkbox.set(true)
        @page.filter_protocols.apply_filter_button.click
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

        @page.filter_protocols.select_status('approved')
        @page.filter_protocols.apply_filter_button.click
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
      @page.filter_protocols.search_field.set('title')
      @page.filter_protocols.apply_filter_button.click
      wait_for_javascript_to_finish
      expect(@page.displayed_protocol_ids.sort).to eq [protocol1.id, protocol2.id]
    end

    it 'should match against title case insensitively' do
      protocol1 = create(:protocol_federally_funded, :without_validations, primary_pi: jug2, type: 'Project', archived: false, title: 'titlex')
      protocol2 = create(:protocol_federally_funded, :without_validations, primary_pi: jug2, type: 'Project', archived: false, title: 'xTitle')
      create(:protocol_federally_funded, :without_validations, primary_pi: jug2, type: 'Project', archived: false, title: 'aaa')
      visit_protocols_index_page
      @page.filter_protocols.search_field.set('title')
      @page.filter_protocols.apply_filter_button.click
      wait_for_javascript_to_finish
      expect(@page.displayed_protocol_ids.sort).to eq [protocol1.id, protocol2.id]
    end

    it 'should match against id' do
      protocol1 = create(:protocol_federally_funded, :without_validations, primary_pi: jug2, type: 'Project', archived: false)
      create(:protocol_federally_funded, :without_validations, primary_pi: jug2, type: 'Project', archived: false)
      create(:protocol_federally_funded, :without_validations, primary_pi: jug2, type: 'Project', archived: false)
      visit_protocols_index_page
      @page.filter_protocols.search_field.set(protocol1.id.to_s)
      @page.filter_protocols.apply_filter_button.click
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
      @page.filter_protocols.search_field.set('name1')
      @page.filter_protocols.apply_filter_button.click
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
      @page.filter_protocols.search_field.set('name1')
      @page.filter_protocols.apply_filter_button.click
      wait_for_javascript_to_finish
      expect(@page.displayed_protocol_ids.sort).to eq [protocol1.id, protocol2.id]
    end
  end

  describe 'my protocols' do
    context 'user is a service provider and a superuser for an Organization' do
      let!(:organization) { create(:organization, admin: jug2) }

      it 'should show the My Protocols checkbox' do
        visit_protocols_index_page
        expect(@page.filter_protocols).to have_my_protocols_checkbox
        expect(@page.filter_protocols.my_protocols_checkbox).to be_checked
      end

      context 'user unchecks My Protocols and clicks the filter button' do
        it 'should display all Protocols' do
          protocol1 = create(:protocol_federally_funded, :without_validations, primary_pi: create(:identity), type: 'Project', archived: false)
          protocol2 = create(:protocol_federally_funded, :without_validations, primary_pi: jug2, type: 'Project', archived: false)
          visit_protocols_index_page
          @page.filter_protocols.my_protocols_checkbox.click
          @page.filter_protocols.apply_filter_button.click
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
        expect(@page.filter_protocols).to have_no_my_protocols_checkbox
      end
    end
  end

  describe 'my admin organizations' do
    describe 'defaults' do
      include_context 'authorized Organizations'

      it 'should not restrict listing to Protocols with SSR\'s in user\'s authorized Organizations' do
        p1 = create(:protocol_federally_funded, :without_validations, primary_pi: jug2, type: 'Project', archived: false)
        create(:service_request_without_validations, protocol: p1, organizations: [org1])

        p2 = create(:protocol_federally_funded, :without_validations, primary_pi: jug2, type: 'Project', archived: false)
        create(:service_request_without_validations, protocol: p2, organizations: [create(:organization)])

        visit_protocols_index_page
        expect(@page.displayed_protocol_ids.sort).to eq [p1.id, p2.id]
        expect(@page.filter_protocols.my_admin_organizations_checkbox).to_not be_checked
      end
    end

    context 'user checks My Admin Organizations and clicks the filter button' do
      include_context 'authorized Organizations'

      it 'should only display Protocols contain SSR\'s belonging to user\'s authorized Organizations' do
        p1 = create(:protocol_federally_funded, :without_validations, primary_pi: jug2, type: 'Project', archived: false)
        create(:service_request_without_validations, protocol: p1, organizations: [org1])

        p2 = create(:protocol_federally_funded, :without_validations, primary_pi: jug2, type: 'Project', archived: false)
        create(:service_request_without_validations, protocol: p2, organizations: [create(:organization)])

        visit_protocols_index_page
        @page.filter_protocols.my_admin_organizations_checkbox.click
        @page.filter_protocols.apply_filter_button.click
        wait_for_javascript_to_finish
        expect(@page.displayed_protocol_ids.sort).to eq [p1.id]
      end
    end

    context 'user unchecks previously checked My Admin Organizations and clicks the filter button' do
      include_context 'authorized Organizations'

      it 'should not restrict listing to Protocols with SSR\'s in user\'s authorized Organizations' do
        p1 = create(:protocol_federally_funded, :without_validations, primary_pi: jug2, type: 'Project', archived: false)
        create(:service_request_without_validations, protocol: p1, organizations: [org1])

        p2 = create(:protocol_federally_funded, :without_validations, primary_pi: jug2, type: 'Project', archived: false)
        create(:service_request_without_validations, protocol: p2, organizations: [create(:organization)])

        visit_protocols_index_page
        @page.filter_protocols.my_admin_organizations_checkbox.click
        @page.filter_protocols.apply_filter_button.click
        wait_for_javascript_to_finish
        @page.filter_protocols.my_admin_organizations_checkbox.click
        @page.filter_protocols.apply_filter_button.click
        wait_for_javascript_to_finish

        expect(@page.displayed_protocol_ids.sort).to eq [p1.id, p2.id]
      end
    end
  end

  describe 'core dropdown' do
    describe 'defaults' do
      include_context 'authorized Organizations'

      it 'should not restrict listing to Protocols with SSR\'s in a particular user-authorized Organization' do
        p1 = create(:protocol_federally_funded, :without_validations, primary_pi: jug2, type: 'Project', archived: false)
        create(:service_request_without_validations, protocol: p1, organizations: [org1])

        p2 = create(:protocol_federally_funded, :without_validations, primary_pi: jug2, type: 'Project', archived: false)
        create(:service_request_without_validations, protocol: p2, organizations: [org2])

        p3 = create(:protocol_federally_funded, :without_validations, primary_pi: jug2, type: 'Project', archived: false)
        create(:service_request_without_validations, protocol: p3, organizations: [create(:organization)])

        visit_protocols_index_page

        expect(@page.displayed_protocol_ids.sort).to eq [p1.id, p2.id, p3.id]
      end

      it 'should not select anything in dropdown' do
        p1 = create(:protocol_federally_funded, :without_validations, primary_pi: jug2, type: 'Project', archived: false)
        create(:service_request_without_validations, protocol: p1, organizations: [org1])

        visit_protocols_index_page
        expect(@page.filter_protocols.selected_core).to eq '- Any -'
      end
    end

    context 'user selects an Organization by name and clicks the Filter button' do
      include_context 'authorized Organizations'

      it 'should restrict listing to Protocols with SSR\'s belonging to that Organization' do
        p1 = create(:protocol_federally_funded, :without_validations, primary_pi: jug2, type: 'Project', archived: false)
        create(:service_request_without_validations, protocol: p1, organizations: [org1])

        p2 = create(:protocol_federally_funded, :without_validations, primary_pi: jug2, type: 'Project', archived: false)
        create(:service_request_without_validations, protocol: p2, organizations: [org1, org2])

        p3 = create(:protocol_federally_funded, :without_validations, primary_pi: jug2, type: 'Project', archived: false)
        create(:service_request_without_validations, protocol: p3, organizations: [create(:organization)])

        visit_protocols_index_page
        @page.filter_protocols.select_core(org1.name)
        @page.filter_protocols.apply_filter_button.click
        wait_for_javascript_to_finish

        expect(@page.displayed_protocol_ids.sort).to eq [p1.id, p2.id]
      end
    end

    context 'user deselects a previously selected Organization and clicks the Filter button' do
      include_context 'authorized Organizations'

      it 'should not restrict listing to Protocols with SSR\'s belonging to any particular Organization' do
        p1 = create(:protocol_federally_funded, :without_validations, primary_pi: jug2, type: 'Project', archived: false)
        create(:service_request_without_validations, protocol: p1, organizations: [org1])

        p2 = create(:protocol_federally_funded, :without_validations, primary_pi: jug2, type: 'Project', archived: false)
        create(:service_request_without_validations, protocol: p2, organizations: [org1, org2])

        p3 = create(:protocol_federally_funded, :without_validations, primary_pi: jug2, type: 'Project', archived: false)
        create(:service_request_without_validations, protocol: p3, organizations: [create(:organization)])

        visit_protocols_index_page
        @page.filter_protocols.select_core(org1.name)
        @page.filter_protocols.apply_filter_button.click
        wait_for_javascript_to_finish
        @page.filter_protocols.core_select.click
        @page.filter_protocols.core_options.first.click
        @page.filter_protocols.apply_filter_button.click
        wait_for_javascript_to_finish

        expect(@page.displayed_protocol_ids.sort).to eq [p1.id, p2.id, p3.id]
      end
    end
  end
end
