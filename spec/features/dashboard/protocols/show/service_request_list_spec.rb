# Copyright © 2011-2016 MUSC Foundation for Research Development~
# All rights reserved.~

# Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:~

# 1. Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.~

# 2. Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following~
# disclaimer in the documentation and/or other materials provided with the distribution.~

# 3. Neither the name of the copyright holder nor the names of its contributors may be used to endorse or promote products~
# derived from this software without specific prior written permission.~

# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING,~
# BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT~
# SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL~
# DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS~
# INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR~
# TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.~

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
      context 'when user presses Add Note button and saves a note' do
        it 'should create a new Note and display it in modal' do
          service_request = create(:service_request_without_validations,
                                   protocol: protocol,
                                   status: 'draft')
          create(:sub_service_request,
                 service_request: service_request,
                 organization: create(:organization),
                 status: 'draft')

          page = go_to_show_protocol(protocol.id)
          page.service_requests.first.notes_button.click
          page.index_notes_modal.instance_exec do
            new_note_button.click
            wait_for_message_area
            message_area.set('my important note')
            add_note_button.click
          end

          expect(page.index_notes_modal).to have_notes(text: 'my important note')
          expect(Note.count).to eq 1
        end
      end
    end
  end

  describe 'displayed SubServiceRequest' do
    let!(:protocol) { create(:unarchived_study_without_validations, primary_pi: user) }
    let!(:service_request) do
      create(:service_request_without_validations,
      protocol: protocol,
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
        organization_id: organization.id,
        status: 'draft')
    end

    describe 'sending notifications' do
      context 'user clicks Send Notification' do
        context 'user selects themselves in dropdown' do
          it 'should alert user that notifications cannot be sent to themselves' do
            page = go_to_show_protocol(protocol.id)
            wait_for_javascript_to_finish
            first_ssr = page.service_requests.first.ssrs.first

            first_ssr.send_notification_select.click
            first_ssr.wait_until_recipients_visible

            accept_alert(with: 'You can not send a message to yourself.') do
                first_ssr.recipients.find { |li| li.text == 'Primary-pi: John Doe' }.click
            end
          end
        end

        context 'user selects someone other than themselves in dropdown and fills in modal' do
          it 'should send a notification to that user' do
            page = go_to_show_protocol(protocol.id)
            wait_for_javascript_to_finish
            first_ssr = page.service_requests.first.ssrs.first
            easter_bunny = Identity.where(first_name: "Easter", last_name: "Bunny").first

            # open potential recipients for a notification
            first_ssr.send_notification_select.click
            first_ssr.wait_until_recipients_visible
            # Select the service requester, say
            first_ssr.recipients.find { |li| li.text == 'Easter Bunny' }.click
            # fill in and submit notification
            page.wait_for_new_notification_form
            page.new_notification_form.instance_exec do
              subject_field.set 'Hello'
              message_field.set 'Hows it going?'
              submit_button.click
            end
            expect(page).to have_no_new_notification_form

            note = sub_service_request.notifications.last
            message = Message.first
            expect(note.subject).to eq 'Hello'
            expect(note.originator_id).to eq user.id
            expect(note.other_user_id).to eq easter_bunny.id
            expect(message.to).to eq easter_bunny.id
            expect(message.from).to eq user.id
            expect(message.body).to eq 'Hows it going?'
            expect(message.notification_id).to eq note.id
          end
        end
      end
    end
  end

  describe 'buttons' do
    let!(:protocol) { create(:unarchived_study_without_validations, primary_pi: user) }
    let!(:service_request) do
      create(:service_request_without_validations,
        protocol: protocol,
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
        organization_id: organization.id,
        status: 'draft')
    end

    scenario 'user clicks "Modify Request" button' do
      page = go_to_show_protocol(protocol.id)
      wait_for_javascript_to_finish

      page.service_requests.first.modify_request_button.click

      expect(URI.parse(current_url).path).to eq "/service_requests/#{service_request.id}/catalog"
    end

    scenario 'user clicks "View" button' do
      page = go_to_show_protocol(protocol.id)
      wait_for_javascript_to_finish

      page.service_requests.first.ssrs.first.view_button.click

      page.wait_for_view_ssr_modal
      expect(page).to have_view_ssr_modal
    end

    scenario 'user clicks "Edit" button' do
      page = go_to_show_protocol(protocol.id)
      wait_for_javascript_to_finish

      page.service_requests.first.ssrs.first.edit_button.click

      expect(URI.parse(current_url).path).to eq "/service_requests/#{service_request.id}/catalog"
    end

    scenario 'user clicks "Admin Edit" button' do
      page = go_to_show_protocol(protocol.id)
      wait_for_javascript_to_finish

      page.service_requests.first.ssrs.first.admin_edit_button.click

      expect(URI.parse(current_url).path).to eq '/dashboard/sub_service_requests/9999'
    end
  end
end
