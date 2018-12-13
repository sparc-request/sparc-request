# Copyright © 2011-2018 MUSC Foundation for Research Development
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

RSpec.describe 'User edits epic answers', js: true do
  let_there_be_lane
  fake_login_for_each_test
  build_study_type_question_groups
  build_study_type_questions

  stub_config("research_master_enabled", true)
  
  context "RMID server is up and running" do
    before :each do
      @protocol       = create(:protocol_without_validations,
                                type: "Study",
                                primary_pi: jug2,
                                funding_status: "funded",
                                funding_source: "foundation")
      organization    = create(:organization)
      service_request = create(:service_request_without_validations,
                                protocol: @protocol)
                        create(:sub_service_request_without_validations,
                                organization: organization,
                                service_request: service_request,
                                status: 'draft')
                        create(:super_user, identity: jug2,
                                organization: organization,
                                access_empty_protocols: true)

      allow(Protocol).to receive(:rmid_status).and_return(true)
    end

    context 'and clicks Edit Information' do
      scenario 'and sees the edit page' do
        visit edit_dashboard_protocol_path(@protocol)
        wait_for_javascript_to_finish
        expect(page).to have_content('Change Protocol Type')
      end

       scenario 'and does not see server down message' do
        visit edit_dashboard_protocol_path(@protocol)
        wait_for_javascript_to_finish
        expect(page).not_to have_content( I18n.t(:protocols)[:summary][:tooltips][:rmid_server_down] )
      end
    end
    
    context 'and edits information and submits' do
      scenario 'and sees updated protocol' do
        visit edit_dashboard_protocol_path(@protocol)
        wait_for_javascript_to_finish

        fill_in 'protocol_short_title', with: 'Now this is a short title all about how my life got flipped-turned upside down'

        click_button 'Save'
        wait_for_javascript_to_finish

        expect(@protocol.reload.short_title).to eq('Now this is a short title all about how my life got flipped-turned upside down')
      end
    end
  end

  context "RMID server is down" do
    before :each do
      @protocol       = create(:protocol_without_validations,
                                type: "Study",
                                primary_pi: jug2,
                                funding_status: "funded",
                                funding_source: "foundation")
      organization    = create(:organization)
      service_request = create(:service_request_without_validations,
                                protocol: @protocol)
                        create(:sub_service_request_without_validations,
                                organization: organization,
                                service_request: service_request,
                                status: 'draft')
                        create(:super_user, identity: jug2,
                                organization: organization)

      allow(Protocol).to receive(:rmid_status).and_return(false)
    end

    context 'and clicks Edit Information' do
      scenario 'and sees that the rmid server is down through flash message' do
        visit edit_dashboard_protocol_path(@protocol)
        wait_for_javascript_to_finish

        expect(page).to have_content( I18n.t(:protocols)[:summary][:tooltips][:rmid_server_down] )
      end

      scenario 'and sees that the rmid server is down through disabled rmid field' do
        visit edit_dashboard_protocol_path(@protocol)
        wait_for_javascript_to_finish

        expect(page).to have_css '.research-master-field:disabled'
      end

      scenario 'and sees that the rmid server is down through red exclamation' do
        visit edit_dashboard_protocol_path(@protocol)
        wait_for_javascript_to_finish

        expect(page).to have_css '.glyphicon.glyphicon-exclamation-sign.text-danger'
      end
    end
  end
end