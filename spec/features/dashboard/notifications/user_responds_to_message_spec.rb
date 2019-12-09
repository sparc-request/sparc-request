# Copyright © 2011-2019 MUSC Foundation for Research Development
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

RSpec.describe "User responds to a message", js: true do
  let_there_be_lane
  fake_login_for_each_test

  let(:other_user) { create(:identity) }

  it 'should create a new message' do
    protocol      = create(:study_federally_funded, primary_pi: jug2)
    sr            = create(:service_request, protocol: protocol)
    ssr           = create(:sub_service_request, service_request: sr, protocol: protocol, organization: create(:organization))
    notification  = create(:notification, originator: other_user, other_user: jug2, sub_service_request: ssr)
                    create(:message, sender: other_user, recipient: jug2, notification: notification, body: 'Hello there')

    visit root_path
    wait_for_javascript_to_finish

    expect(page).to have_selector('.profile .notification-badge')

    find('#profileDropdown').hover
    find('#profileDropdown + .dropdown-menu .dropdown-item#userMessages').click
    wait_for_javascript_to_finish

    expect(page).to have_selector('.notifications-table tbody tr', count: 1)

    # Capybara doesn't like to click td elements
    first('.notifications-table tbody tr td.subject span').click
    wait_for_javascript_to_finish

    expect(page).to have_no_selector('.profile .notification-badge')

    fill_in 'message_body', with: 'General Kenobi'

    click_button I18n.t('actions.reply')
    wait_for_javascript_to_finish

    expect(notification.reload.messages.count).to eq(2)
    expect(jug2.reload.sent_messages.count).to eq(1)
    expect(other_user.reload.received_messages.count).to eq(1)
    expect(page).to have_selector('.card-callout p', text: 'General Kenobi')
  end
end
