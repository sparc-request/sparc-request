require 'rails_helper'

RSpec.describe 'requests modal', js: true do
  let_there_be_lane
  fake_login_for_each_test

  let!(:protocol) { create(:protocol_federally_funded, :without_validations, primary_pi: jug2, type: 'Study', archived: false) }
  let!(:sr) { create(:service_request_without_validations, protocol: protocol, service_requester: jug2) }
  let!(:ssr) { create(:sub_service_request, ssr_id: '0001', service_request: sr, organization: create(:organization)) }

  def open_modal
    @page = Dashboard::Protocols::IndexPage.new
    @page.load
    expect(@page).to have_protocols
    @page.protocols.first.requests_button.click
    @page.requests_modal.service_requests.first.notes_button.click
    @notes_modal = @page.index_notes_modal
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
