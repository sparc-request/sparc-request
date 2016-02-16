require 'rails_helper'

RSpec.describe 'requests modal', js: true do
  let_there_be_lane
  fake_login_for_each_test

  def visit_protocols_index_page
    @page = Dashboard::Protocols::IndexPage.new
    @page.load
    wait_for_javascript_to_finish
  end

  def open_modal
    visit_protocols_index_page
    @page.protocols.first.requests_button.click
    @requests_modal = @page.requests_modal
  end

  context 'ServiceRequest with no SubServiceRequests' do
    let!(:protocol) { create(:protocol_federally_funded,  :without_validations, primary_pi: jug2, type: 'Study', archived: false) }

    it 'should not be displayed in ServiceRequest list' do
      service_request_with_ssr = create(:service_request_without_validations, protocol: protocol, service_requester: jug2)
      create(:sub_service_request, ssr_id: '0001', service_request: service_request_with_ssr, organization: create(:organization))
      create(:service_request_without_validations, protocol: protocol, service_requester: jug2)
      open_modal
      expect(@requests_modal.service_requests.count).to eq 1
      expect(@requests_modal.service_requests.first.header.text).to start_with "Service Request: #{service_request_with_ssr.id}"
    end
  end

  context 'SubServiceRequest in first_draft belongs to ServiceRequest' do
    let!(:protocol) { create(:protocol_federally_funded,  :without_validations, primary_pi: jug2, type: 'Study', archived: false) }

    it 'should not be displayed in SubServiceRequestList' do
      service_request = create(:service_request_without_validations, protocol: protocol, service_requester: jug2)
      create(:sub_service_request, ssr_id: '0001', service_request: service_request, organization: create(:organization), status: 'first_draft')
      open_modal
      expect(@requests_modal.service_requests.first).to have_no_sub_service_requests
    end
  end

  context 'SubServiceRequest not in first_draft belongs to ServiceRequest' do
    let!(:protocol) { create(:protocol_federally_funded,  :without_validations, primary_pi: jug2, type: 'Study', archived: false) }

    let!(:service_request) { create(:service_request_without_validations, protocol: protocol, service_requester: jug2) }
    let!(:organization) { create(:organization, name: 'Organization 1') }
    let!(:sub_service_request) { create(:sub_service_request, ssr_id: '0001', service_request: service_request, organization: organization, status: 'draft') }
    before(:each) do
      open_modal
      @sub_service_requests = @requests_modal.service_requests.first.sub_service_requests
    end

    it 'should display <protocol_id>-<ssr_id>' do
      expect(@sub_service_requests.first.pretty_ssr_id.text).to eq "#{protocol.id}-#{sub_service_request.ssr_id}"
    end

    it 'should display SSR\'s Organization' do
      expect(@sub_service_requests.first.organization.text).to eq 'Organization 1'
    end

    it 'should display SSR\'s status' do
      expect(@sub_service_requests.first.status.text).to eq 'Draft'
    end
  end

  it 'should be titled by the Protocol\'s short title' do
    protocol = create(:protocol_federally_funded, :without_validations, type: 'Study', archived: false, short_title: 'My Protocol', primary_pi: jug2)
    service_request = create(:service_request_without_validations, protocol: protocol, service_requester: create(:identity))
    create(:sub_service_request, ssr_id: '0001', service_request: service_request, organization: create(:organization), status: 'draft')

    open_modal

    expect(@requests_modal.title.text).to eq protocol.short_title
  end

  context 'user can edit ServiceRequest' do
    it 'should display \'Edit Original\' button' do
    end
  end

  context 'user cannot edit ServiceRequest' do
    it 'should not display \'Edit Original\' button' do
    end
  end

  describe 'actions' do
    describe 'View SSR button' do
      let!(:protocol) { create(:protocol_federally_funded,  :without_validations, primary_pi: jug2, type: 'Study', archived: false) }
      it 'TODO: pending'
    end

    describe 'Edit SSR button' do
      context 'user can edit SubServiceRequest' do
        let!(:protocol) { create(:protocol_federally_funded,  :without_validations, primary_pi: jug2, type: 'Study', archived: false) }

        let!(:service_request) { create(:service_request_without_validations, protocol: protocol, service_requester: jug2) }
        let!(:organization) { create(:organization, name: 'Organization 1') }
        let!(:sub_service_request) { create(:sub_service_request, ssr_id: '0001', service_request: service_request, organization: organization, status: EDITABLE_STATUSES.first) }
        before(:each) do
          create(:project_role, identity: jug2, project_rights: 'approve')
          open_modal
          @sub_service_requests = @requests_modal.service_requests.first.sub_service_requests
        end

        it 'should show the button' do
          expect(@sub_service_requests.first).to have_edit_ssr_button
        end
      end

      context 'user cannot edit SubServiceRequest' do
        it 'should not show the button' do
          protocol = create(:protocol_federally_funded,  :without_validations, type: 'Study', archived: false)
          service_request = create(:service_request_without_validations, protocol: protocol, service_requester: create(:identity))
          organization = create(:organization, name: 'Organization 1')
          create(:sub_service_request, ssr_id: '0001', service_request: service_request, organization: organization, status: 'draft')
          create(:project_role, identity: jug2, project_rights: 'not-approve', protocol: protocol)
          open_modal
          sub_service_requests = @requests_modal.service_requests.first.sub_service_requests

          expect(sub_service_requests.first).to have_no_edit_ssr_button
        end
      end

      it 'TODO: pending'
    end

    shared_context 'authorized Organizations' do
    end

    describe 'Admin Edit button' do
      describe 'visibility' do
        let!(:protocol) { create(:protocol_federally_funded, :without_validations, type: 'Study', archived: false, primary_pi: jug2) }
        let!(:service_request) { create(:service_request_without_validations, protocol: protocol, service_requester: create(:identity)) }

        context 'SSR belongs to one of user\'s admin Organizations' do
          let!(:admin_org) { create(:organization, admin: jug2, name: 'Organization 1') }
          let!(:sub_service_request) { create(:sub_service_request, ssr_id: '0001', service_request: service_request, organization: admin_org, status: 'draft') }

          it 'should be visible' do
            open_modal
            expect(@requests_modal.service_requests.first.sub_service_requests.first).to have_admin_edit_button
          end
        end

        context 'SSR does not belong to one of user\'s admin Organizations' do
          let!(:sub_service_request) { create(:sub_service_request, ssr_id: '0001', service_request: service_request, organization: create(:organization), status: 'draft') }

          it 'should not be visible' do
            open_modal
            expect(@requests_modal.service_requests.first.sub_service_requests.first).to have_no_admin_edit_button
          end
        end
      end

      context 'user clicks button' do
        it 'should direct to SSR show page' do
          protocol = create(:protocol_federally_funded, :without_validations, primary_pi: jug2, type: 'Study', archived: false)
          service_request = create(:service_request_without_validations, protocol: protocol, service_requester: jug2)
          organization = create(:organization, admin: jug2, name: 'Organization 2')
          sub_service_request = create(:sub_service_request, ssr_id: '0001', service_request: service_request, organization: organization, status: EDITABLE_STATUSES.first)
          open_modal
          expect(@requests_modal.service_requests.first.sub_service_requests.first.admin_edit_button['href']).to eq "/dashboard/sub_service_requests/#{sub_service_request.id}"
          # @requests_modal.service_requests.first.sub_service_requests.first.admin_edit_button.click
          # expect(@page.current_url).to end_with "/dashboard/sub_service_requests/#{sub_service_request.id}"
        end
      end
    end
  end
end
