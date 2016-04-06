require 'rails_helper'

RSpec.describe 'service request list', js: true do
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

  def go_to_show_protocol(protocol_id)
    page = Dashboard::Protocols::ShowPage.new
    page.load(id: protocol_id)
    page
  end

  describe 'displayed ServiceRequest' do
    let!(:protocol) { create(:unarchived_study_without_validations, primary_pi: user) }

    describe 'notes button' do
      context 'ServiceRequest has notes' do
        before(:each) do
          Note.create(identity_id: user.id, notable_type: 'ServiceRequest', notable_id: sr.id, body: 'hey')
          open_modal
        end

        # TODO extract
        xit 'should show previously added notes' do
          expect(@notes_modal.notes.first.comment.text).to eq 'hey'
        end
      end

      context 'when user presses Add Note button and saves a note' do
        it 'should create a new Note and display it in modal' do
          service_request = create(:service_request_without_validations,
                                   protocol: protocol,
                                   service_requester: user,
                                   status: 'draft')
          create(:sub_service_request,
                 service_request: service_request,
                 organization: create(:organization))

          page = go_to_show_protocol(protocol.id)
          page.service_requests.ssr_lists.first.notes_button.click
          modal = page.index_notes_modal
          modal.instance_exec do
            new_note_button.click
            wait_for_message_area
            message_area.set('my important note')
            add_note_button.click
          end

          expect(modal).to have_notes(text: 'my important note')
          expect(Note.count).to eq 1
        end
      end
    end
  end

  describe 'displayed SubServiceRequest' do
    let!(:protocol) do
      create(:protocol_federally_funded,
        :without_validations,
        primary_pi: user,
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
        it 'should show service requester, associated users, and service providers partitioned in dropdown' do
          page = go_to_show_protocol(protocol.id)

          @actions_td = page.service_requests.ssr_lists.first.ssrs.first.actions
          @actions_td.send_notification_select.click
          expect(@actions_td).to have_new_notification_dropdown
          expect(@actions_td.new_notification_dropdown.list_items.map(&:text).select(&:present?)).to eq ['Requester', 'Requester: Some Guy', 'Authorized Users', 'Primary-pi: John Doe', 'Clinical Providers', 'Easter Bunny']
        end

        context 'user selects themselves in dropdown' do
          it 'should alert user that notifications cannot be sent to themselves' do
            page = go_to_show_protocol(protocol.id)
            @actions_td = page.service_requests.ssr_lists.first.ssrs.first.actions
            @actions_td.send_notification_select.click
            expect(@actions_td).to have_new_notification_dropdown
            accept_alert(with: 'You can not send a message to yourself.') do
              @actions_td.
                new_notification_dropdown.
                list_items.
                find { |li| li.text == 'Primary-pi: John Doe' }.
                click
            end
          end
        end

        context 'user selects someone other than themselves in dropdown and fills in modal' do
          it 'should send a notification to that user' do
            page = go_to_show_protocol(protocol.id)
            @actions_td = page.service_requests.ssr_lists.first.ssrs.first.actions
            @actions_td.send_notification_select.click
            expect(@actions_td).to have_new_notification_dropdown
            # Select the service requester, say
            @actions_td.
              new_notification_dropdown.
              list_items.
              find { |li| li.text == 'Requester: Some Guy' }.
              click
            # fill in and submit modal
            expect(page).to have_new_notification_form
            page.new_notification_form.subject_field.set 'Hello'
            page.new_notification_form.message_field.set 'Hows it going?'
            page.new_notification_form.submit_button.click
            expect(page).to have_no_new_notification_form

            note = sub_service_request.notifications.last
            message = Message.first
            expect(note.subject).to eq 'Hello'
            expect(note.originator_id).to eq user.id
            expect(note.other_user_id).to eq service_requester.id
            expect(message.to).to eq service_requester.id
            expect(message.from).to eq user.id
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
        primary_pi: user,
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
        admin: user,
        service_provider: create(:identity, first_name: 'Easter', last_name: 'Bunny'))
    end
    let!(:sub_service_request) do
      create(:sub_service_request,
        id: 9999,
        ssr_id: '1234',
        service_request: service_request,
        organization_id: organization.id)
    end

    it 'user clicks "Edit Original" button' do
      page = go_to_show_protocol(protocol.id)

      page.service_requests.ssr_lists.first.edit_original_button.click

      expect(URI.parse(current_url).path).to eq "/service_requests/#{service_request.id}/catalog"
    end

    it 'user clicks "View SSR" button' do
      page = go_to_show_protocol(protocol.id)

      page.service_requests.ssr_lists.first.ssrs.first.view_ssr_button.click

      expect(page).to have_view_ssr_modal
    end

    it 'user clicks "Edit SSR" button' do
      page = go_to_show_protocol(protocol.id)

      page.service_requests.ssr_lists.first.ssrs.first.edit_ssr_button.click

      expect(URI.parse(current_url).path).to eq "/service_requests/#{service_request.id}/catalog"
    end

    scenario 'user clicks "Admin Edit" button' do
      page = go_to_show_protocol(protocol.id)

      page.service_requests.ssr_lists.first.ssrs.first.admin_edit_button.click

      expect(URI.parse(current_url).path).to eq '/dashboard/sub_service_requests/9999'
    end
  end
end
