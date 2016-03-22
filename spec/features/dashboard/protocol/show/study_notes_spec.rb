require 'rails_helper'

RSpec.describe 'Show protocol Study notes spec', js: true do
  let_there_be_lane
  fake_login_for_each_test

  let!(:protocol) { create(:protocol_federally_funded, :without_validations, primary_pi: jug2, type: 'Study', archived: false) }

  def open_modal
    @page = Dashboard::Protocols::ShowPage.new
    @page.load(id: protocol.id)
    # expect(@page).to have_protocols
    # @page.protocols.first.requests_button.click
    # @page.requests_modal.service_requests.first.notes_button.click
    @page.protocol_summary.study_notes_button.click
    @notes_modal = @page.index_notes_modal
  end

  context 'Protocol has notes' do
    before(:each) do
      Note.create(identity_id: jug2.id, notable_type: 'Protocol', notable_id: protocol.id, body: 'hey')
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

    it 'should create a new Note and display it in modal' do
      expect(@notes_modal.notes.first.comment.text).to eq 'hey!'
      expect(Note.count).to eq 1
    end
  end
end
