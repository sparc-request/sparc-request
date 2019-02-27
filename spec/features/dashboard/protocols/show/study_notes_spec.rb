# Copyright © 2011-2019 MUSC Foundation for Research Development~
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

  before :each do
    @page = Dashboard::Protocols::ShowPage.new
    @page.load(id: protocol.id)
    @page.protocol_summary.study_notes_button.click
    @page.wait_for_index_notes_modal
  end

  context 'when user presses Add Note button and saves a note' do
    it 'should create a new Note and display it in modal' do
      @page.index_notes_modal.instance_exec do
        new_note_button.click
      end

      @page.wait_for_note_form_modal

      @page.note_form_modal.instance_exec do
        message_area.set('my important note')
        add_note_button.click
      end

      @page.wait_for_index_notes_modal

      expect(@page.index_notes_modal).to have_notes(text: 'my important note')
      expect(Note.count).to eq 1
    end
  end
end
