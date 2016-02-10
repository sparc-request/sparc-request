require 'rails_helper'

RSpec.describe 'service request list', js: true do
  let_there_be_lane
  fake_login_for_each_test

  def go_to_show_protocol(protocol_id)
    @page = Dashboard::Protocols::ShowPage.new
    @page.load(id: protocol_id)
  end

  describe 'ServiceRequest display' do
    context 'Protocol has at least one ServiceRequest' do
      let!(:protocol) { create(:protocol_federally_funded,  :without_validations, primary_pi: jug2, type: 'Study', archived: false) }


      context 'Protocol only has first_draft requests' do
        let!(:service_request) { create(:service_request_without_validations, protocol: protocol, service_requester: jug2, status: 'first_draft') }
        let!(:sub_service_request) { create(:sub_service_request, ssr_id: '0001', service_request: service_request, organization: create(:organization)) }

        before(:each) { go_to_show_protocol protocol.id }

        it 'should indicate that the request is still in progress' do
          expect(@page.service_requests).to have_content 'Request in progress.'
        end
      end

      context 'Protocol has a non-first_draft request' do
        let!(:service_request_d) do
          sr = create(:service_request_without_validations, protocol: protocol, service_requester: jug2, status: 'draft')
          create(:sub_service_request, ssr_id: '0001', service_request: sr, organization: create(:organization))
          sr
        end
        let!(:service_request_fd) do
          sr = create(:service_request_without_validations, protocol: protocol, service_requester: jug2, status: 'first_draft')
          create(:sub_service_request, ssr_id: '0001', service_request: sr, organization: create(:organization))
          sr
        end
        let!(:service_request_d_no_ssr) { create(:service_request_without_validations, protocol: protocol, service_requester: jug2, status: 'draft') }

        before(:each) { go_to_show_protocol protocol.id }

        it 'should not display ServiceRequests with no SubServiceRequests' do
          expect(@page.service_requests.displayed_ids).not_to include service_request_d_no_ssr.id.to_s
        end

        it 'should not display ServiceRequests in first_draft' do
          expect(@page.service_requests.displayed_ids).not_to include service_request_fd.id.to_s
        end

        it 'should display non-first_draft ServiceRequests with SubServiceRequests' do
          expect(@page.service_requests.displayed_ids).not_to include service_request_d.id.to_s
        end
      end
    end

    context 'Protocol has no ServiceRequests' do
      let!(:protocol) { create(:protocol_federally_funded,  :without_validations, primary_pi: jug2, type: 'Study', archived: false) }

      before(:each) { go_to_show_protocol protocol.id }

      it 'should show a button to add services' do
        expect(@page.service_requests).to have_add_services_button
      end
    end
  end

  describe 'displayed ServiceRequest' do
    let!(:protocol) { create(:protocol_federally_funded, :without_validations, primary_pi: jug2, type: 'Study', archived: false) }

    describe 'header' do
      context 'submitted ServiceRequest' do
        it 'should display id, status, and submitted date' do
          submitted_at = DateTime.now
          service_request = create(:service_request_without_validations, protocol: protocol, service_requester: jug2, status: 'submitted', submitted_at: submitted_at)
          create(:sub_service_request, ssr_id: '0001', service_request: service_request, organization: create(:organization))
          go_to_show_protocol protocol.id

          expect(@page.service_requests.ssr_lists.first.title.text).to eq "Service Request: #{service_request.id} - Submitted - #{submitted_at.strftime('%D')}"
        end
      end

      context 'unsubmitted ServiceRequest' do
        it 'should display id, status, and last modified date' do
          service_request = create(:service_request_without_validations, protocol: protocol, service_requester: jug2, status: 'draft')
          create(:sub_service_request, ssr_id: '0001', service_request: service_request, organization: create(:organization))
          go_to_show_protocol protocol.id

          expect(@page.service_requests.ssr_lists.first.title.text).to eq "Service Request: #{service_request.id} - Draft - #{service_request.updated_at.strftime('%D')}"
        end
      end
    end

    describe 'displayed SubServiceRequests' do
      it 'should not display SubServiceRequests in first_draft' do
        service_request = create(:service_request_without_validations, protocol: protocol, service_requester: jug2, status: 'draft')
        create(:sub_service_request, ssr_id: '1234', service_request: service_request, organization: create(:organization), status: 'first_draft')
        create(:sub_service_request, ssr_id: 'abcd', service_request: service_request, organization: create(:organization), status: 'draft')
        go_to_show_protocol protocol.id

        expect(@page.service_requests.ssr_lists.first).not_to have_content('1234')
        expect(@page.service_requests.ssr_lists.first).to have_content('abcd')
      end
    end
  end

  describe 'displayed SubServiceRequest' do
    let!(:protocol) do
      create(:protocol_federally_funded,
        :without_validations,
        primary_pi: jug2,
        type: 'Study',
        archived: false)
    end
    let!(:service_request) do
      create(:service_request_without_validations,
      protocol: protocol,
      service_requester: create(:identity, first_name: 'Some', last_name: 'Guy'),
      status: 'draft')
    end
    let!(:organization) do
      create(:organization,
        name: 'Megacorp',
        service_provider: create(:identity, first_name: 'Easter', last_name: 'Bunny'))
    end
    let!(:sub_service_request) do
      create(:sub_service_request,
        ssr_id: '1234',
        service_request: service_request,
        organization: organization)
    end

    before(:each) { go_to_show_protocol protocol.id }

    it 'should display <protocol_id>-<ssr_id>' do
      expect(@page.service_requests.ssr_lists.first.ssrs.first).to have_content "#{protocol.id}-1234"
    end

    it 'should display associated Organization' do
      expect(@page.service_requests.ssr_lists.first.ssrs.first).to have_content "Megacorp"
    end

    it 'should display status' do
      expect(@page.service_requests.ssr_lists.first.ssrs.first).to have_content "Draft"
    end

    describe 'sending notifications' do
      context 'user clicks Send Notification' do
        before(:each) do
          @actions_td = @page.service_requests.ssr_lists.first.ssrs.first.actions
          @actions_td.send_notification_select.click
          expect(@actions_td).to have_new_notification_dropdown
        end

        it 'should show service requester, associated users, and service providers partitioned in dropdown' do
          expect(@actions_td.new_notification_dropdown.list_items.map(&:text).select(&:present?)).to eq ['Requester', 'Requester: Some Guy', 'Associated Users', 'Primary-pi: Julia Glenn', 'Service Providers', 'Easter Bunny']
        end

        context 'user selects themselves in dropdown' do
          it 'should alert user that notifications cannot be sent to themselves' do
            accept_alert(with: 'You can not send a message to yourself.') do
              @actions_td.
                new_notification_dropdown.
                list_items.
                find { |li| li.text == 'Primary-pi: Julia Glenn' }.
                click
            end
          end
        end
      end
    end
  end
end
