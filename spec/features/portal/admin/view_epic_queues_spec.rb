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

  describe "if I have special access" do
    before :each do
      let_there_be_lane
      fake_login_for_each_test("jug2@musc.edu")
      visit portal_admin_path
    end

    it "should display the 'View Epic Queue' button" do
      expect(page).to have_text('View Epic Queue')
    end

    describe "clicking the 'View Epic Queue' button" do
      it 'should take me to the Epic Queues portal' do
        find("a.epic_queues").click
        wait_for_javascript_to_finish
        expect(page).to have_text("Queued Protocol")
      end
    end

    describe "viewing the Epic Queues" do
      it 'should display the Epic Queues' do
        protocol = create(:protocol_with_sub_service_request_in_cwf)
        epic_queue = create(:epic_queue, protocol: protocol)
        find("a.epic_queues").click
        wait_for_javascript_to_finish
      end
    end
  end
  
  describe "if I don't have special access" do
    before :each do
      let_there_be_j
      fake_login_for_each_test("jpl6@musc.edu")
      visit portal_admin_path
    end

    it "should not display the 'View Epic Queue' button" do
      expect(page).not_to have_text('View Epic Queue')
    end
  end
end