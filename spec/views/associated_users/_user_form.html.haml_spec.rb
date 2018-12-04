# Copyright © 2011-2018 MUSC Foundation for Research Development~
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

RSpec.describe '/associated_users/_user_form', type: :view do

  let_there_be_lane

  def render_user_form
    protocol = create(:unarchived_study_without_validations, id: 1, primary_pi: jug2, selected_for_epic: true)
    project_role = build(:project_role, id: 1, protocol_id: protocol.id, identity_id: jug2.id, role: 'consultant', epic_access: 0)
    service_request = build(:service_request_without_validations)
    dashboard = false
    assign(:user, jug2)
    render "/associated_users/user_form", header_text: "Edit Authorized User",
                                                   identity: jug2,
                                                   protocol: protocol,
                                                   current_pi: jug2,
                                                   project_role: project_role,
                                                   dashboard: dashboard,
                                                   service_request: service_request,
                                                   admin: false
  end

  context 'When the user views the associated users form' do
    context 'epic configuration turned off' do
      stub_config("use_epic", false)

      it 'should show the correct header and labels' do
        render_user_form
        expect(response).to have_selector('h4', text: "Edit Authorized User")
        expect(response).to have_selector('label', text: t(:authorized_users)[:form_fields][:credentials])
        expect(response).to have_selector('label', text: t(:authorized_users)[:form_fields][:institution])
        expect(response).to have_selector('label', text: t(:authorized_users)[:form_fields][:college])
        expect(response).to have_selector('label', text: t(:authorized_users)[:form_fields][:department])
        expect(response).to have_selector('label', text: t(:authorized_users)[:form_fields][:phone])
        expect(response).to have_selector('label', text: t(:authorized_users)[:form_fields][:role])
        expect(response).to have_selector('label', text: t(:authorized_users)[:rights][:header])
        expect(response).to have_selector('label', text: t(:authorized_users)[:form_fields][:college])
      end

      it 'should show the correct buttons' do
        render_user_form
        expect(response).to have_selector('button', text: t(:actions)[:close])
        expect(response).to have_selector('button', text: t(:actions)[:save])
        expect(response).to have_selector('button.close')
        expect(response).to have_selector('button', count: 3)
      end

      it 'should show the correct form fields when not using epic and protocol is not selected for epic' do
        render_user_form
        expect(response).to have_selector('.radio', count: 3)
        expect(response).to have_selector('.radio-inline', count: 0)
        expect(response).not_to have_selector('label', text: 'No')
        expect(response).not_to have_selector('label', text: 'Yes')
      end
    end

    context 'epic configuration turned on' do
      stub_config("use_epic", true)

      it 'should show the correct form fields when using epic and protocol is selected for epic' do
        render_user_form
        expect(response).to have_selector('label', text: 'No')
        expect(response).to have_selector('label', text: 'Yes')
        expect(response).to have_selector('.radio-inline', count: 2)
      end
    end
  end
end
