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

RSpec.feature 'User wants to add a document', js: true do
  let!(:logged_in_user) { create(:identity, last_name: "Doe", first_name: "John", ldap_uid: "johnd", email: "johnd@musc.edu", password: "p4ssword", password_confirmation: "p4ssword", approved: true) }
  let!(:other_user) { create(:identity, last_name: "Doe", first_name: "Jane", ldap_uid: "janed", email: "janed@musc.edu", password: "p4ssword", password_confirmation: "p4ssword", approved: true) }

  fake_login_for_each_test("johnd")

  context 'and has permission to do so' do
    before :each do
      @protocol = create(:unarchived_study_without_validations, primary_pi: logged_in_user)

      @page = Dashboard::Protocols::ShowPage.new
      @page.load(id: @protocol.id)
      wait_for_javascript_to_finish
    end

    scenario 'and sees the enabled \'Add a New Document\' button' do
      expect(@page).to have_enabled_add_document_button
    end

    context 'and clicks \'Add a New Document\'' do
      before :each do
        give_user_admin_access_to_protocol

        @page.enabled_add_document_button.click
        wait_for_javascript_to_finish
      end

      scenario 'and sees the document modal' do
        expect(@page).to have_document_modal
      end

      scenario 'and sees their admin orgs selected' do
        open_access_dropdown
        expect(@page.document_modal).to have_selector('li.selected', text: @organization.name)
      end

      context 'and fills in the form and submits' do
        before :each do
          fill_out_document_fields
          wait_for_javascript_to_finish
        end

        scenario 'and sees the new document' do
          @page.wait_for_documents(text: 'Protocol')
          expect(@page).to have_documents(text: 'Protocol')
        end
      end
    end
  end

  context 'and does not have permission to do so' do
    before :each do
      protocol = create(:unarchived_study_without_validations, primary_pi: other_user)
      create(:project_role, identity: logged_in_user, protocol: protocol, project_rights: 'view')

      @page = Dashboard::Protocols::ShowPage.new
      @page.load(id: protocol.id)
    end

    scenario 'and sees the disabled \'Add a New Document\' button' do
      expect(@page).to have_disabled_add_document_button
    end
  end

  def give_user_admin_access_to_protocol
    @organization   = create(:organization)
    service_request = create(:service_request_without_validations, protocol: @protocol)
                      create(:sub_service_request_without_validations, organization: @organization, service_request: service_request)
                      create(:super_user, identity: logged_in_user, organization: @organization)
  end

  def fill_out_document_fields
    @page.document_modal.instance_exec do
      doc_type_dropdown.click
      wait_for_dropdown_choices
      dropdown_choices(text: 'Protocol').first.click
    end

    attach_file 'document_document', './spec/fixtures/files/text_document.txt'

    @page.document_modal.upload_button.click
  end

  def open_access_dropdown
    @page.document_modal.instance_exec do
      access_dropdown.click
      wait_for_dropdown_choices
    end
  end
end
