require 'rails_helper'

RSpec.describe 'Show protocol Study notes spec', js: true do
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

  def open_modal
    page = Dashboard::Protocols::ShowPage.new
    page.load(id: protocol.id)
    page.protocol_summary.study_notes_button.click
    page.wait_for_index_notes_modal
    page.index_notes_modal
  end

  context 'when user presses Add Note button and saves a note' do
    it 'should create a new Note and display it in modal' do
      modal = open_modal

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
