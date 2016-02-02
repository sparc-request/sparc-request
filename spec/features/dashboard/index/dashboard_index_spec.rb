require 'rails_helper'

RSpec.describe 'dashboard index', js: :true do
  let_there_be_lane
  fake_login_for_each_test

  def visit_protocols_index_page
    @page = Dashboard::Protocols::IndexPage.new
    @page.load
    wait_for_javascript_to_finish
  end

  describe 'Protocols list' do
    describe 'archive button' do
      context 'archived Project' do
        let!(:protocol) { create(:protocol_federally_funded, :without_validations, primary_pi: jug2, type: 'Project', archived: true) }
        before(:each) do
          visit_protocols_index_page

          # show archived protocols
          @page.filters.archived_checkbox.set(true)
          @page.filters.apply_filter_button.click
          wait_for_javascript_to_finish
        end

        it "should display 'Unarchive Project'" do
          expect(@page.protocols.first.archive_button.text).to eq 'Unarchive Project'
        end

        context 'User clicks button' do
          it 'should unarchive Project' do
            @page.protocols.first.archive_button.click
            wait_for_javascript_to_finish
            expect(protocol.reload.archived).to be false
          end

          it 'should remove Project from table' do
            @page.protocols.first.archive_button.click
            wait_for_javascript_to_finish
            expect(@page.protocols.size).to eq 0
          end
        end
      end

      context 'unarchived Project' do
        let!(:protocol) { create(:protocol_federally_funded, :without_validations, primary_pi: jug2, type: 'Project', archived: false) }
        before(:each) { visit_protocols_index_page }

        it "should display 'Archive Project'" do
          expect(@page.protocols.first.archive_button.text).to eq 'Archive Project'
        end

        context 'User clicks button' do
          it 'should archive Project' do
            @page.protocols.first.archive_button.click
            wait_for_javascript_to_finish
            expect(protocol.reload.archived).to be true
          end

          it 'should remove Project from table' do
            @page.protocols.first.archive_button.click
            wait_for_javascript_to_finish
            expect(@page.protocols.size).to eq 0
          end
        end
      end

      context 'archived Study' do
        let!(:protocol) { create(:protocol_federally_funded, :without_validations, primary_pi: jug2, type: 'Study', archived: true) }
        before(:each) do
          visit_protocols_index_page

          # show archived protocols
          @page.filters.archived_checkbox.set(true)
          @page.filters.apply_filter_button.click
          wait_for_javascript_to_finish
        end

        it "should display 'Unarchive Study'" do
          expect(@page.protocols.first.archive_button.text).to eq 'Unarchive Study'
        end

        context 'User clicks button' do
          it 'should unarchive Study' do
            @page.protocols.first.archive_button.click
            wait_for_javascript_to_finish
            expect(protocol.reload.archived).to be false
          end

          it 'should remove Study from table' do
            @page.protocols.first.archive_button.click
            wait_for_javascript_to_finish
            expect(@page.protocols.size).to eq 0
          end
        end
      end

      context 'unarchived Study' do
        let!(:protocol) { create(:protocol_federally_funded, :without_validations, primary_pi: jug2, type: 'Study', archived: false) }
        before(:each) { visit_protocols_index_page }

        it "should display 'Archive Study'" do
          expect(@page.protocols.first.archive_button.text).to eq 'Archive Study'
        end

        context 'User clicks button' do
          it 'should archive Study' do
            @page.protocols.first.archive_button.click
            wait_for_javascript_to_finish
            expect(protocol.reload.archived).to be true
          end

          it 'should remove Study from table' do
            @page.protocols.first.archive_button.click
            wait_for_javascript_to_finish
            expect(@page.protocols.size).to eq 0
          end
        end
      end
    end

    describe 'requests button' do
      let!(:protocol) { create(:protocol_federally_funded,  :without_validations, primary_pi: jug2, type: 'Study', archived: false) }

      context 'Protocol has no ServiceRequests' do
        before(:each) { visit_protocols_index_page }

        it 'should not display button' do
          expect(@page.protocols.first).to have_no_requests_button
        end
      end

      context 'Protocol has a SubServiceRequest' do
        context 'user clicks the requests button' do
          let!(:service_request) { create(:service_request_without_validations, protocol: protocol, service_requester: jug2) }
          let!(:sub_service_request) { create(:sub_service_request, ssr_id: '0001', service_request: service_request, organization: create(:organization)) }
          before(:each) do
            visit_protocols_index_page
            @protocol_in_list = @page.protocols.first
          end

          before(:each) { @protocol_in_list.requests_button.click }

          it 'should open a modal' do
            expect(@page).to have_requests_modal
          end
        end
      end
    end

  #   describe 'requests modal' do
  #     let!(:protocol) { create(:protocol_federally_funded,  :without_validations, primary_pi: jug2, type: 'Study', archived: false) }
  #     let!(:service_request_with_ssr) { create(:service_request_without_validations, protocol: protocol, service_requester: jug2) }
  #     let!(:sub_service_request) { create(:sub_service_request, ssr_id: '0001', service_request: service_request, organization: create(:organization)) }
  #     let!(:service_request_wo_ssr) { create(:service_request_without_validations, protocol: protocol, service_requester: jug2) }
  #     before(:each) do
  #       visit_protocols_index_page
  #       @page.protocols.first.requests_button.click
  #       @requests_modal = @page.requests_modal
  #     end
  #
  #     it 'should be titled by the Protocol\'s short title' do
  #       expect(@requests_modal.title.text).to eq protocol.short_title
  #     end
  #
  #     it 'should list the associated ServiceRequests that have SubServiceRequests' do
  #       expect(@requests_modal.service_requests.first.pretty_ssrid.text).to eq "#{protocol.id}-#{service_request_with_ssr.ssr_id}"
  #     end
  #
  #     it 'should not list SubServiceRequests in first_draft' do
  #     end
  #
  #     context 'user can edit ServiceRequest' do
  #       it 'should display \'Edit Original\' button' do
  #       end
  #     end
  #
  #     context 'user cannot edit ServiceRequest' do
  #       it 'should not display \'Edit Original\' button' do
  #       end
  #     end
  #   end
  end

  describe 'filters' do
    describe 'archived checkbox' do
      let!(:archived_protocol) { create(:protocol_federally_funded, :without_validations, primary_pi: jug2, type: 'Project', archived: true) }
      let!(:unarchived_protocol) { create(:protocol_federally_funded, :without_validations, primary_pi: jug2, type: 'Project', archived: false) }

      context 'user checks archived checkbox and clicks filter button' do
        it 'should only show archived protocols' do
          visit_protocols_index_page
          @page.filters.archived_checkbox.set(true)
          @page.filters.apply_filter_button.click
          wait_for_javascript_to_finish
          expect(@page.displayed_protocol_ids).to eq [archived_protocol.id]
        end
      end

      context 'user unchecks previously checked checkbox and clicks filter button' do
        it 'should only show unarchived protocols' do
          visit_protocols_index_page
          @page.filters.archived_checkbox.set(true)
          @page.filters.apply_filter_button.click
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
      it 'should match against short title' do
        protocol = create(:protocol_federally_funded, :without_validations, primary_pi: jug2, type: 'Project', archived: false, short_title: 'CCC')
        create(:protocol_federally_funded, :without_validations, primary_pi: jug2, type: 'Project', archived: false, short_title: 'DDD')
        visit_protocols_index_page
        @page.filters.search_field.set('C')
        @page.filters.apply_filter_button.click
        wait_for_javascript_to_finish
        expect(@page.displayed_protocol_ids).to eq [protocol.id]
      end

      it 'should match against title' do
        protocol = create(:protocol_federally_funded, :without_validations, primary_pi: jug2, type: 'Project', archived: false, title: 'CCC')
        create(:protocol_federally_funded, :without_validations, primary_pi: jug2, type: 'Project', archived: false, title: 'DDD')
        visit_protocols_index_page
        @page.filters.search_field.set('C')
        @page.filters.apply_filter_button.click
        wait_for_javascript_to_finish
        expect(@page.displayed_protocol_ids).to eq [protocol.id]
      end

      it 'should match against id' do
      end

      it 'should match against associated users\' first name' do
      end

      it 'should match against associated users\' last name' do
      end
    end

    describe 'my protocols' do
      describe 'defaults' do
        it 'should not display archived Protocols' do
          create(:protocol_federally_funded, :without_validations, primary_pi: jug2, type: 'Project', archived: true)
          visit_protocols_index_page
          expect(@page).to have_no_protocols
        end

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
      end

      context 'user unchecks My Protocols and clicks the filter button' do
      end

      context 'user checks previously unchecked My Protocols and clicks the filter button' do
      end
    end
  end
end
