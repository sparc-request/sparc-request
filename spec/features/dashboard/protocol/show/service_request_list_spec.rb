require 'rails_helper'

RSpec.describe 'service request list', js: true do
  let_there_be_lane
  fake_login_for_each_test

  def go_to_show_protocol(protocol_id)
    @page = Dashboard::Protocols::ShowPage.new
    @page.load(id: protocol_id)
  end

  describe 'displayed ServiceRequest' do
    let!(:protocol) { create(:protocol_federally_funded, :without_validations, primary_pi: jug2, type: 'Study', archived: false) }

    describe 'notes button' do
      def open_modal
        go_to_show_protocol protocol.id
        @page.service_requests.ssr_lists.first.notes_button.click
        @notes_modal = @page.index_notes_modal
      end

      let!(:sr) { create(:service_request_without_validations, protocol: protocol, service_requester: jug2, status: 'draft') }

      before(:each) do
        create(:sub_service_request, ssr_id: '0001', service_request: sr, organization: create(:organization))
      end

      context 'ServiceRequest has notes' do
        before(:each) do
          Note.create(identity_id: jug2.id, notable_type: 'ServiceRequest', notable_id: sr.id, body: 'hey')
          open_modal
        end

        it 'should show previously added notes' do
          expect(@notes_modal.notes.first.comment.text).to eq 'hey'
        end
      end

      context 'when user presses Add Note button and saves a note' do
        before(:each) do
          open_modal
          @notes_modal.new_note_button.click
          @page.new_notes_modal.input_field.set 'hey!'
          @page.new_notes_modal.add_note_button.click
        end

        it 'should display new note in modal' do
          expect(@notes_modal.notes.first.comment.text).to eq 'hey!'
        end

        it 'should create a new Note' do
          wait_for_javascript_to_finish
          expect(Note.count).to eq 1
        end
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
    let!(:service_requester) { create(:identity, first_name: 'Some', last_name: 'Guy') }
    let!(:service_request) do
      create(:service_request_without_validations,
      protocol: protocol,
      service_requester: service_requester,
      status: 'draft')
    end
    let!(:organization) do
      create(:organization,
        type: 'Institution',
        name: 'Megacorp',
        service_provider: create(:identity, first_name: 'Easter', last_name: 'Bunny'))
    end
    let!(:sub_service_request) do
      create(:sub_service_request,
        ssr_id: '1234',
        service_request: service_request,
        organization_id: organization.id)
    end

    describe 'sending notifications' do
      context 'user clicks Send Notification' do
        before(:each) do
          go_to_show_protocol protocol.id
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

        context 'user selects someone other than themselves in dropdown and fills in modal' do
          before(:each) do
            @actions_td.
              new_notification_dropdown.
              list_items.
              find { |li| li.text == 'Requester: Some Guy' }.
              click

            expect(@page).to have_new_notification_form
            @page.new_notification_form.subject_field.set 'Hello'
            @page.new_notification_form.message_field.set 'Hows it going?'
            @page.new_notification_form.submit_button.click
            expect(@page).to have_no_new_notification_form
          end

          it 'should send a notification to that user' do
            note = sub_service_request.notifications.last
            message = Message.first
            expect(note.subject).to eq 'Hello'
            expect(note.originator_id).to eq jug2.id
            expect(note.other_user_id).to eq service_requester.id
            expect(message.to).to eq service_requester.id
            expect(message.from).to eq jug2.id
            expect(message.body).to eq 'Hows it going?'
            expect(message.notification_id).to eq note.id
          end
        end
      end
    end
  end

  describe 'buttons' do
    let!(:protocol) do
      create(:protocol_federally_funded,
        :without_validations,
        primary_pi: jug2,
        type: 'Study',
        archived: false)
    end
    let!(:service_requester) { create(:identity, first_name: 'Some', last_name: 'Guy') }
    let!(:service_request) do
      create(:service_request_without_validations,
      protocol: protocol,
      service_requester: service_requester,
      status: 'draft')
    end
    let!(:organization) do
      create(:organization,
        type: 'Institution',
        name: 'Megacorp',
        admin: jug2,
        service_provider: create(:identity, first_name: 'Easter', last_name: 'Bunny'))
    end
    let!(:sub_service_request) do
      create(:sub_service_request,
        id: 9999,
        ssr_id: '1234',
        service_request: service_request,
        organization_id: organization.id)
    end

    before(:each) { go_to_show_protocol protocol.id }

    scenario 'user clicks "Edit Original" button' do
      @page.service_requests.ssr_lists.first.edit_original_button.click
    end

    scenario 'user clicks "View SSR" button' do
      @page.service_requests.ssr_lists.first.ssrs.first.view_ssr_button.click
    end

    scenario 'user clicks "Edit SSR" button' do
      @page.service_requests.ssr_lists.first.ssrs.first.edit_ssr_button.click
    end

    scenario 'user clicks "Admin Edit" button' do
      @page.service_requests.ssr_lists.first.ssrs.first.admin_edit_button.click
      expect(URI.parse(current_url).path).to eq '/dashboard/sub_service_requests/9999'
    end
  end
end
