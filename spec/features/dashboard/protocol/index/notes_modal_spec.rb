require 'rails_helper'

RSpec.describe 'requests modal', js: true do
  let_there_be_lane
  fake_login_for_each_test

  let!(:protocol) { create(:protocol_federally_funded, :without_validations, primary_pi: jug2, type: 'Study', archived: false) }
  let!(:sr) { create(:service_request_without_validations, protocol: protocol, service_requester: jug2) }
  let!(:ssr) { create(:sub_service_request, ssr_id: '0001', service_request: sr, organization: create(:organization)) }

  def index_page
    unless @page
      @page = Dashboard::Protocols::IndexPage.new
      @page.load
      expect(@page).to have_protocols
    end
    @page
  end

  def index_notes_modal
    unless @index_notes_modal
      index_page.protocols.first.requests_button.click
      index_page.requests_modal.service_requests.first.notes_button.click
      @index_notes_modal ||= index_page.index_notes_modal
    end
    @index_notes_modal
  end

  def new_notes_modal
    index_page.new_notes_modal
  end

  context 'ServiceRequest has notes' do
    before(:each) do
      Note.create(identity_id: jug2.id, notable_type: 'ServiceRequest', notable_id: sr.id, body: 'my important note')
    end

    it 'should show previously added notes' do
      expect(index_notes_modal.notes.first.comment.text).to eq 'my important note'
    end
  end

  context 'when user presses Add Note button and saves a note' do
    before(:each) do
      index_notes_modal.new_note_button.click
      new_notes_modal.input_field.set 'my important note'
      new_notes_modal.add_note_button.click
    end

    it 'should create a new Note and display it in modal' do
      expect(index_notes_modal.notes.first.comment.text).to eq 'my important note'
      expect(Note.count).to eq 1
    end
  end
end
