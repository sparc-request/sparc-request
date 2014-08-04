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

require 'spec_helper'

describe "admin related service requests tab", :js => true do
  let_there_be_lane
  let_there_be_j
  fake_login_for_each_test
  build_service_request_with_project

  before :each do
    add_visits
    visit portal_admin_sub_service_request_path sub_service_request.id
    find("a.related_service_requests-tab").click
    wait_for_javascript_to_finish
  end

  it "should list the service request" do
    within "div#related_service_requests" do
      find("#requests tr td:first").should have_content("#{sub_service_request.ssr_id}")
    end
  end

  it "should show the first service when the plus link is clicked" do
    find("div#requests td a.rsr-link").click
    wait_for_javascript_to_finish
    find("div#ssr_#{sub_service_request.id}").should have_content("#{sub_service_request.line_items.first.service.name}")
  end

  it "should also show the second service when the plus link is clicked" do
    find("div#requests td a.rsr-link").click
    wait_for_javascript_to_finish
    find("div#ssr_#{sub_service_request.id}").should have_content("#{sub_service_request.line_items.last.service.name}")
  end

end
