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

RSpec.describe "User views documents table", js: true do

  let!(:logged_in_user) { create(:identity, last_name: "Doe", first_name: "John", ldap_uid: "johnd", email: "johnd@musc.edu", password: "p4ssword", password_confirmation: "p4ssword", approved: true) }
  let!(:other_user) { create(:identity, last_name: "Doe", first_name: "Jane", ldap_uid: "janed", email: "janed@musc.edu", password: "p4ssword", password_confirmation: "p4ssword", approved: true) }

  fake_login_for_each_test("johnd")

  def go_to_show_protocol(protocol_id)
    page = Dashboard::Protocols::ShowPage.new
    page.load(id: protocol_id)
    page
  end

  context 'and has permission to edit' do
    let!(:protocol) { create(:unarchived_study_without_validations, primary_pi: logged_in_user) }
    let!(:document) { create(:document, protocol: protocol) }

    scenario 'and sees the document link and enabled edit/delete buttons' do
      page = go_to_show_protocol(protocol.id)

      expect(page).to have_selector('td.title a', text: document.document_file_name)
      expect(page.documents.first).to have_enabled_edit_button
      expect(page.documents.first).to have_enabled_remove_button
    end
  end

  context 'and does not have permission to edit' do
    let!(:protocol)     { create(:unarchived_study_without_validations, primary_pi: other_user) }
    let!(:project_role) { create(:project_role, protocol: protocol, identity: logged_in_user, project_rights: 'view') }
    let!(:document)     { create(:document, protocol: protocol) }

    scenario 'and sees the document title (no link) and disabled edit/delete buttons' do
      page = go_to_show_protocol(protocol.id)

      expect(page).not_to have_selector('td.title a', text: document.document_file_name)
      expect(page).to have_selector('td.title', text: document.document_file_name)
      expect(page.documents.first).to have_disabled_edit_button
      expect(page.documents.first).to have_disabled_remove_button
    end
  end

  context 'and has admin privileges for a document' do
    let!(:protocol)             { create(:unarchived_study_without_validations, primary_pi: other_user) }
    let!(:organization)         { create(:organization) }
    let!(:super_user)           { create(:super_user, organization: organization, identity: logged_in_user) }
    let!(:service_request)      { create(:service_request_without_validations, protocol: protocol) }
    let!(:ssr)                  { create(:sub_service_request_without_validations, service_request: service_request, organization: organization, status: 'draft') }
    let!(:document_with_access) { create(:document, protocol: protocol, doc_type: 'Protocol') }
    let!(:document_no_access)   { create(:document, protocol: protocol, doc_type: 'Consent') }

    before :each do
      document_with_access.sub_service_requests = [ssr]
      document_with_access.reload
      @page = go_to_show_protocol(protocol.id)
      wait_for_javascript_to_finish
    end

    scenario 'and sees the document link and enabled edit/delete buttons for access documents' do
      doc = @page.documents(text: document_with_access.document_file_name).first

      expect(doc).to have_selector('td.title a', text: document_with_access.document_file_name)
      expect(doc).to have_enabled_edit_button
      expect(doc).to have_enabled_remove_button
    end

    scenario 'and sees the document title (no link) and disabled edit/delete buttons for no access documents' do
      doc = @page.documents(text: document_no_access.document_file_name).first
      
      expect(doc).not_to have_selector('td.title a', text: document_no_access.document_file_name)
      expect(doc).to have_selector('td.title', text: document_no_access.document_file_name)
      expect(doc).to have_disabled_edit_button
      expect(doc).to have_disabled_remove_button
    end
  end
end
