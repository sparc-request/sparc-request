require 'rails_helper'

RSpec.describe 'dashboard index', js: :true do
  let_there_be_lane
  fake_login_for_each_test

  def visit_protocols_index_page
    @page = Dashboard::Protocols::IndexPage.new
    @page.load
    wait_for_javascript_to_finish
  end

  describe 'new protocol button' do
    before(:each) { visit_protocols_index_page }

    context 'user clicks button and selects Study from dropdown' do
      it 'should navigate to the correct page' do
        @page.new_protocol('Study')
        expect(@page.current_url).to end_with "/dashboard/protocols/new?protocol_type=study"
      end
    end

    context 'user clicks button and selects Project from dropdown' do
      it 'should navigate to the correct page' do
        @page.new_protocol('Project')
        expect(@page.current_url).to end_with "/dashboard/protocols/new?protocol_type=project"
      end
    end
  end

  describe 'Protocols list' do
    describe 'archive button' do
      context 'archived Project' do
        let!(:protocol) { create(:protocol_federally_funded, :without_validations, primary_pi: jug2, type: 'Project', archived: true) }
        before(:each) do
          visit_protocols_index_page

          # show archived protocols
          @page.filter_protocols.archived_checkbox.click
          @page.filter_protocols.apply_filter_button.click
          wait_for_javascript_to_finish
        end

        context 'User clicks button' do
          it do
            @page.protocols.first.archive_button.click
            wait_for_javascript_to_finish
            protocol.reload
            expect(protocol.archived).to be(false), "expected protocol.archived to be false, got #{protocol.archived}"
            expect(@page.protocols.size).to eq(0), 'expected protocol to be removed from list, got non-empty list'
          end
        end
      end

      context 'unarchived Project' do
        let!(:protocol) { create(:protocol_federally_funded, :without_validations, primary_pi: jug2, type: 'Project', archived: false) }
        before(:each) { visit_protocols_index_page }

        context 'User clicks button' do
          it do
            @page.protocols.first.archive_button.click
            wait_for_javascript_to_finish
            protocol.reload
            expect(protocol.archived).to be(true), "expected protocol.archived to be true, got #{protocol.archived}"
            expect(@page.protocols.size).to eq(0), 'expected protocol to be removed from list, got non-empty list'
          end
        end
      end

      context 'archived Study' do
        let!(:protocol) { create(:protocol_federally_funded, :without_validations, primary_pi: jug2, type: 'Study', archived: true) }
        before(:each) do
          visit_protocols_index_page

          # show archived protocols
          @page.filter_protocols.archived_checkbox.click
          @page.filter_protocols.apply_filter_button.click
          wait_for_javascript_to_finish
        end

        context 'User clicks button' do
          it do
            @page.protocols.first.archive_button.click
            wait_for_javascript_to_finish
            protocol.reload
            expect(protocol.archived).to be(false), "expected protocol.archived to be false, got #{protocol.archived}"
            expect(@page.protocols.size).to eq(0), 'expected protocol to be removed from list, got non-empty list'
          end
        end
      end

      context 'unarchived Study' do
        let!(:protocol) { create(:protocol_federally_funded, :without_validations, primary_pi: jug2, type: 'Study', archived: false) }
        before(:each) { visit_protocols_index_page }

        context 'User clicks button' do
          it do
            @page.protocols.first.archive_button.click
            wait_for_javascript_to_finish
            expect(protocol.reload.archived).to be(true), "expected protocol.archived to be true, got #{protocol.archived}"
            expect(@page.protocols.size).to eq(0), 'expected protocol to be removed from list, got non-empty list'
          end
        end
      end
    end

    describe 'requests button' do
      let!(:protocol) { create(:protocol_federally_funded,  :without_validations, primary_pi: jug2, type: 'Study', archived: false) }

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
  end
end
