require 'rails_helper'

RSpec.describe 'dashboard index', js: :true do
  let_there_be_lane
  fake_login_for_each_test

  def visit_protocols_index_page
    page = Dashboard::Protocols::IndexPage.new
    page.load
    wait_for_javascript_to_finish
    page
  end

  describe 'new protocol button' do
    context 'user clicks button and selects Study from dropdown' do
      it 'should navigate to the correct page' do
        page = visit_protocols_index_page

        page.new_protocol_button.click
        page.new_study_option.click

        expect(page.current_url).to end_with "/dashboard/protocols/new?protocol_type=study"
      end
    end

    context 'user clicks button and selects Project from dropdown' do
      it 'should navigate to the correct page' do
        page = visit_protocols_index_page

        page.new_protocol_button.click
        page.new_project_option.click

        expect(page.current_url).to end_with "/dashboard/protocols/new?protocol_type=project"
      end
    end
  end

  describe 'Protocols list' do
    describe 'archive button' do
      context 'archived Project' do
        scenario 'User clicks button' do
          protocol = create(:protocol_federally_funded, :without_validations, primary_pi: jug2, type: 'Project', archived: true)
          page = visit_protocols_index_page
          # show archived protocols
          page.filter_protocols.archived_checkbox.click
          page.filter_protocols.apply_filter_button.click
          wait_for_javascript_to_finish

          page.protocols.first.unarchive_project_button.click
          wait_for_javascript_to_finish
          protocol.reload
          expect(protocol.archived).to be(false), "expected protocol.archived to be false, got #{protocol.archived}"
          expect(page.protocols.size).to eq(0), 'expected protocol to be removed from list, got non-empty list'
        end
      end

      context 'unarchived Project' do
        scenario 'User clicks button' do
          protocol = create(:protocol_federally_funded, :without_validations, primary_pi: jug2, type: 'Project', archived: false)
          page = visit_protocols_index_page

          page.protocols.first.archive_project_button.click
          wait_for_javascript_to_finish
          protocol.reload
          expect(protocol.archived).to be(true), "expected protocol.archived to be true, got #{protocol.archived}"
          expect(page.protocols.size).to eq(0), 'expected protocol to be removed from list, got non-empty list'
        end
      end

      context 'archived Study' do
        scenario 'User clicks button' do
          protocol = create(:protocol_federally_funded, :without_validations, primary_pi: jug2, type: 'Study', archived: true)
          page = visit_protocols_index_page

          # show archived protocols
          page.filter_protocols.archived_checkbox.click
          page.filter_protocols.apply_filter_button.click
          wait_for_javascript_to_finish

          page.protocols.first.unarchive_study_button.click
          wait_for_javascript_to_finish
          protocol.reload
          expect(protocol.archived).to be(false), "expected protocol.archived to be false, got #{protocol.archived}"
          expect(page.protocols.size).to eq(0), 'expected protocol to be removed from list, got non-empty list'
        end
      end

      context 'unarchived Study' do
        scenario 'User clicks button' do
          protocol = create(:protocol_federally_funded, :without_validations, primary_pi: jug2, type: 'Study', archived: false)
          page = visit_protocols_index_page

          page.protocols.first.archive_study_button.click
          wait_for_javascript_to_finish
          expect(protocol.reload.archived).to be(true), "expected protocol.archived to be true, got #{protocol.archived}"
          expect(page.protocols.size).to eq(0), 'expected protocol to be removed from list, got non-empty list'
        end
      end
    end

    describe 'requests button' do
      context 'Protocol has a SubServiceRequest' do
        scenario 'user clicks the requests button' do
          protocol = create(:protocol_federally_funded,  :without_validations, primary_pi: jug2, type: 'Study', archived: false)
          service_request = create(:service_request_without_validations, protocol: protocol, service_requester: jug2)
          create(:sub_service_request, ssr_id: '0001', service_request: service_request, organization: create(:organization))

          page = visit_protocols_index_page
          page.protocols.first.requests_button.click

          expect(page).to have_requests_modal
        end
      end
    end
  end
end
