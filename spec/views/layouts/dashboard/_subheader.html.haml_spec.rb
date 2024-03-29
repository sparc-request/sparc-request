# Copyright © 2011-2022 MUSC Foundation for Research Development~
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

RSpec.describe 'layouts/dashboard/_subheader.html.haml', view: true do
  include RSpecHtmlMatchers

  before(:each) do
    @user = instance_double(Identity,
      ldap_uid: 'jug2',
      email: 'user@email.com',
      catalog_overlord?: true,
      unread_notification_count: 2,
      )

    session[:breadcrumbs] = Dashboard::Breadcrumber.new
    expect(session[:breadcrumbs]).to receive(:breadcrumbs).and_return('All those other pages.')
  end

  it 'should display breadcrumbs by sending :breadcrumbs to session[:breadcrumbs]' do
    render 'layouts/dashboard/subheader', current_user: @user

    expect(response).to have_content('All those other pages.')
  end

  context 'epic configuration turned on' do
    stub_config("use_epic", true)
    stub_config("epic_queue_access", ['jug2'])

    it 'should display view epic queue button' do
      render 'layouts/dashboard/subheader', current_user: @user

      expect(response).to have_selector('a', text: I18n.t('layout.dashboard.navigation.epic_queue'))
    end
  end

  context 'OnCore configuration turned on' do
    stub_config("use_oncore", true)
    stub_config("oncore_endpoint_access", ['jug2'])

    it 'should display view OnCore Log button' do
      render 'layouts/dashboard/subheader', current_user: @user

      expect(response).to have_selector('a', text: I18n.t('layout.dashboard.navigation.oncore_log'))
    end
  end

  context 'short interaction turned on' do
    stub_config('use_short_interaction', true)

    before :each do
      allow(@user).to receive(:is_service_provider?).and_return(true)
    end

    it 'should display the short interaction button' do
      render 'layouts/dashboard/subheader', current_user: @user

      expect(response).to have_selector('a', text: I18n.t('layout.dashboard.navigation.protocol_merge'))
    end
  end
end
