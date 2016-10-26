# Copyright © 2011-2016 MUSC Foundation for Research Development
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

RSpec.feature 'User wants to edit a document', js: true do
  let!(:logged_in_user) { create(:identity, last_name: "Doe", first_name: "John", ldap_uid: "johnd", email: "johnd@musc.edu", password: "p4ssword", password_confirmation: "p4ssword", approved: true) }

  fake_login_for_each_test("johnd")

  before :each do
    @protocol = create(:unarchived_study_without_validations, primary_pi: logged_in_user)
                create(:document, protocol: @protocol, doc_type: 'Protocol')

    @page = Dashboard::Protocols::ShowPage.new
    @page.load(id: @protocol.id)
    wait_for_javascript_to_finish
  end

  context 'and clicks the Edit button' do
    before :each do
      @page.documents.first.enabled_edit_button.click
      wait_for_javascript_to_finish
    end

    scenario 'and sees the document modal' do
      expect(@page).to have_document_modal
    end

    context 'and edits a field and submits' do
      before :each do
        edit_document_fields
        wait_for_javascript_to_finish
      end

      scenario 'and sees the updated document' do
        @page.wait_for_documents(text: 'Protocol')
        expect(@page).to have_documents(text: 'Consent')
      end
    end
  end

  def edit_document_fields
    @page.document_modal.instance_exec do
      doc_type_dropdown.click
      wait_for_dropdown_choices
      dropdown_choices(text: 'Consent').first.click
    end

    attach_file 'document_document', './spec/fixtures/files/text_document.txt'

    @page.document_modal.upload_button.click
  end
end
