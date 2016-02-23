# Copyright © 2011 MUSC Foundation for Research Development
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

RSpec.describe 'view epic queues', js: true do

  let_there_be_lane
  let_there_be_j
  build_service_request_with_study

  describe "if I have special access" do

    fake_login_for_each_test

    it "should display the 'View Epic Queue' button" do
      visit portal_admin_index_path
      wait_for_javascript_to_finish

      ########
      # Make sure that jug2 is listed
      # in the test environment for config/application.yml
      # queue_epic_edit_ldap_uids: ['jug2']
      # #######
      expect(page).to have_text('View Epic Queue')
    end

    describe "clicking the 'View Epic Queue' button" do
      it 'should take me to the Epic Queues portal' do
        visit portal_admin_index_path
        wait_for_javascript_to_finish
        find("a.epic_queues").click
        wait_for_javascript_to_finish
        expect(page).to have_text("Queued Protocol")
      end
    end

    describe "viewing the Epic Queues" do
      it 'should display the Epic Queues' do
        protocol = Protocol.first
        create(:epic_queue, protocol: protocol)
        visit portal_epic_queues_path
        wait_for_javascript_to_finish
        expect(page).to have_text("#{protocol.short_title}")
      end
    end
  end
  
  describe "if I don't have special access" do

    fake_login_for_each_test('jpl6@musc.edu')

    it "should not display the 'View Epic Queue' button" do
      visit portal_admin_index_path
      wait_for_javascript_to_finish
      expect(page).not_to have_text('View Epic Queue')
    end
  end
end