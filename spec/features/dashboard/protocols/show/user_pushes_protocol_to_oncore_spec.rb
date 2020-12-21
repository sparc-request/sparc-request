# Copyright © 2011-2020 MUSC Foundation for Research Development~
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

RSpec.describe 'User pushes a study to OnCore', js: true do
  let_there_be_lane
  fake_login_for_each_test

  stub_config("use_oncore", true)
  stub_config("oncore_endpoint_access", ['jug2'])

  let(:auth_path) { "/forte-platform-web/api/oauth/token" }
  let(:protocols_path) { "/oncore-api/rest/protocols" }
  let(:contacts_path) { "/oncore-api/rest/contacts" }
  let(:protocol_institutions_path) { "/oncore-api/rest/protocolInstitutions" }
  let(:protocol_staff_path) { "/oncore-api/rest/protocolStaff" }

  before :each do
    @study = create(:study_federally_funded, primary_pi: jug2)

    visit dashboard_protocol_path(@study)
    wait_for_javascript_to_finish
    click_link I18n.t('protocols.summary.oncore.push_to_oncore')
    wait_for_javascript_to_finish
  end

  context 'OnCore servers accessible' do
    context 'and the protocol does not yet exist in OnCore' do
      it 'should post a protocol to OnCore' do
        expect(a_request(:post, Setting.get_value("oncore_api")+protocols_path)).to have_been_made.once
        expect(a_request(:post, Setting.get_value("oncore_api")+protocol_institutions_path)).to have_been_made.once
        expect(a_request(:post, Setting.get_value("oncore_api")+protocol_staff_path)).to have_been_made.once
      end
    end

    context 'and the protocol has already been pushed to OnCore', oncore_protocol: :exists do
      it 'should only attempt to push the base protocol' do
        expect(a_request(:post, Setting.get_value("oncore_api")+protocols_path)).to have_been_made.once
      end

      it 'should display an error' do
        expect(page).to have_content(I18n.t('protocols.summary.oncore.error'))
        expect(page).to have_content(I18n.t('protocols.summary.oncore.already_exists', protocol_id: @study.id))
      end
    end
  end

  context 'OnCore servers inaccessible', remote_service: :unavailable do
    it 'should contact OnCore servers once' do
      expect(a_request(:post, Setting.get_value("oncore_api")+auth_path)).to have_been_made.once
    end

    it 'should display HTTP error' do
      expect(page).to have_content(I18n.t('protocols.summary.oncore.error'))
      expect(page).to have_content('500:')
    end
  end
end
