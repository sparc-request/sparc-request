# Copyright © 2011-2016 MUSC Foundation for Research Development~
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

RSpec.describe 'layouts/dashboard/_dashboard_header.html.haml', view: true do
  include RSpecHtmlMatchers

  before(:each) do
    @user = instance_double(Identity,
      ldap_uid: 'jug2',
      email: 'user@email.com',
      unread_notification_count: 2,
      )

    session[:breadcrumbs] = Dashboard::Breadcrumber.new
    expect(session[:breadcrumbs]).to receive(:breadcrumbs).and_return('All those other pages.')
  end

  it 'should display view epic queue button' do
    render 'layouts/dashboard/dashboard_header', user: @user

    expect(response).to have_selector('button#epic-queue-btn', text: 'View Epic Queue')
  end

  it 'should display number of unread notifications (for user)' do
    @show_messages = true
    render 'layouts/dashboard/dashboard_header', user: @user

    expect(response).to have_selector('button#messages-btn span.badge', text: '2')
  end

  it 'should display breadcrumbs by sending :breadcrumbs to session[:breadcrumbs]' do
    render 'layouts/dashboard/dashboard_header', user: @user

    expect(response).to have_content('All those other pages.')
  end

  it 'should display welcome message to user' do
    render 'layouts/dashboard/dashboard_header', user: @user

    expect(response).to have_content(t(:dashboard)[:navbar][:logged_in_as] + "user@email.com")
    expect(response).to have_tag('a', text: "Logout")
  end
end
