require 'rails_helper'

RSpec.describe 'requests modal', js: true do
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

  let!(:protocol) { create(:unarchived_study_without_validations, primary_pi: user) }
  let!(:sr) { create(:service_request_without_validations, protocol: protocol, service_requester: user) }
  let!(:ssr) { create(:sub_service_request, service_request: sr, organization: create(:organization)) }

  def index_page
    page = Dashboard::Protocols::IndexPage.new
    page.load
    page
  end

  context 'when user presses Add Note button and saves a note' do
    it 'should create a new Note and display it in modal' do
      page = index_page
      page.instance_exec do
        search_results.protocols.first.requests_button.click
        wait_for_requests_modal
        requests_modal.service_requests.first.notes_button.click
        wait_for_index_notes_modal
        index_notes_modal.instance_exec do
          new_note_button.click
          wait_for_message_area
          message_area.set('my important note')
          add_note_button.click
        end
      end

      expect(page.index_notes_modal).to have_notes(text: 'my important note')
      expect(Note.count).to eq 1
    end
  end
end
