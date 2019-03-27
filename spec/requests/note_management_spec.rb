# Copyright © 2011-2019 MUSC Foundation for Research Development
# All rights reserved.

# Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:

# 1. Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.

# 2. Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following
# disclaimer in the documentation and/or other materials provided with the distribution.

# 3. Neither the name of the copyright holder nor the names of its contributors may be used to endorse or promote products
# derived from this software without specific prior written permission.

# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING,
# BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT
# SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
# DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
# INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR
# TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

require 'rails_helper'

RSpec.describe "Note Management", type: :request, js: true do

  let!(:current_user) {
    build_stubbed(:identity)
  }

  let!(:line_item) {
    create(:line_item_without_validations, service: create(:service))
  }

  before :each do
    allow_any_instance_of(ApplicationController).to receive(:current_user).and_return(current_user)
  end

  it 'should display the notes table' do
    get notes_url, params: { note: { notable_id: line_item.id, notable_type: LineItem.name }, format: :js }, xhr: true

    expect(response).to render_template(:index)
    expect(response.body).to include("id=\\'notes-table\\'")
  end

  it 'should create a note' do
    expect{
      get new_note_url, params: { note: { notable_id: line_item.id, notable_type: LineItem.name }, format: :js }, xhr: true
      expect(response).to render_template(:new)

      post notes_url, params: { note: { identity_id: current_user.id, notable_id: line_item.id, notable_type: LineItem.name, body: "test" }, format: :js }, xhr: true
      expect(response).to render_template(:create)

      expect(response.body).to include(I18n.t(:notes)[:created])
    }.to change(Note, :count).by(1)
  end

  it 'should update a note' do
    note = create(:note, notable: line_item, identity: current_user, body: 'test')

    expect{
      get edit_note_url(note), params: { note: { notable_id: note.notable_id, notable_type: note.notable_type }, format: :js }, xhr: true
      expect(response).to render_template(:edit)

      put note_url(note), params: { note: { notable_id: note.notable_id, notable_type: note.notable_type, body: 'duly noted' }, format: :js }, xhr: true
      expect(response).to render_template(:update)

      expect(response.body).to include(I18n.t(:notes)[:updated])
      note.reload
    }.to change(note, :body).to('duly noted')
  end

  it 'should destroy a note' do
    note = create(:note, notable: line_item, identity: current_user)

    expect{
      delete note_url(note), params: { note: { notable_id: note.notable_id, notable_type: note.notable_type }, format: :js }, xhr: true
      expect(response).to render_template(:destroy)
    }.to change(Note, :count).by(-1)
  end
end
