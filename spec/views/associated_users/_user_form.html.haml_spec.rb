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

RSpec.describe '/associated_users/_user_form', type: :view do

  let_there_be_lane

  def render_user_form(opts={})
    protocol = create(:unarchived_study_without_validations, id: 1, primary_pi: jug2, selected_for_epic: true)
    project_role = build(:project_role, id: 1, protocol_id: protocol.id, identity_id: jug2.id, role: 'consultant', epic_access: 0)
    service_request = build(:service_request_without_validations)
    dashboard = false
    assign(:user, jug2)
    render "/associated_users/user_form", opts.merge({
                                                   identity: jug2,
                                                   protocol: protocol,
                                                   protocol_role: project_role,
                                                   service_request: service_request,
                                                  })
  end

  describe 'header' do
    context 'new user' do
      it 'should display the correct header' do
        render_user_form(action_name: 'new')

        expect(response).to have_text(I18n.t('authorized_users.new'))
      end
    end

    context 'edit user' do
      it 'should display the correct header' do
        render_user_form(action_name: 'edit')

        expect(response).to have_text(I18n.t('authorized_users.edit'))
      end
    end
  end

  describe 'epic radios' do
    context 'epic turned on' do
      stub_config('use_epic', true)

      it 'should display the radios' do
        render_user_form

        expect(response).to have_content(ProjectRole.human_attribute_name(:epic_access))
        expect(response).to have_selector('#project_role_epic_access_true')
        expect(response).to have_selector('#project_role_epic_access_false')
      end

      context 'validate epic users turned on' do
        stub_config('validate_epic_users', true)

        context 'epic user is active' do
          before :each do
            allow(EpicUser).to receive(:is_active?).with('').and_return(true)
          end

          it 'should allow editing' do
            render_user_form({ epic_user: '' })

            expect(response).to have_selector('#project_role_epic_access_true:not([disabled=disabled])')
            expect(response).to have_selector('#project_role_epic_access_false:not([disabled=disabled])')
            expect(response).to have_content(I18n.t('authorized_users.form.no_epic_access'))
          end
        end

        context 'epic user is not active' do
          before :each do
            allow(EpicUser).to receive(:is_active?).with('').and_return(false)
          end

          it 'should not allow editing' do
            render_user_form({ epic_user: '' })

            expect(response).to have_selector('#project_role_epic_access_true[disabled=disabled]')
            expect(response).to have_selector('#project_role_epic_access_false[disabled=disabled]')
            expect(response).to have_content(I18n.t('authorized_users.form.no_epic_access'))
          end
        end
      end
    end

    context 'epic turned off' do
      stub_config('use_epic', false)

      it 'should not display the radios' do
        render_user_form

        expect(response).to have_no_content(ProjectRole.human_attribute_name(:epic_access))
        expect(response).to have_no_selector('#project_role_epic_access_true')
        expect(response).to have_no_selector('#project_role_epic_access_false')
      end
    end
  end
end
