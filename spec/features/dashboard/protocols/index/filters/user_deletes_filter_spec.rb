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

require "rails_helper"

RSpec.describe "User deletes a filter", js: :true do

  let_there_be_lane
  fake_login_for_each_test

  before :each do
    @protocol1 = create(:study_without_validations, primary_pi: jug2, title: "title%", short_title: "Protocol1")
    @protocol2 = create(:study_without_validations, primary_pi: jug2, title: "xTitle", short_title: "Protocol2")
    @protocol3 = create(:study_without_validations, primary_pi: jug2, title: "a%a", short_title: "Protocol3")

    service_request1 = create(:service_request_without_validations, protocol: @protocol1)
    service_request2 = create(:service_request_without_validations, protocol: @protocol2)
    service_request3 = create(:service_request_without_validations, protocol: @protocol3)

    create(:protocol_filter, identity: jug2)

    visit dashboard_protocols_path
    wait_for_javascript_to_finish

    expect(page).to have_selector(".protocols_index_row", count: 3)
  end

  it 'should delete the filter' do
    page.execute_script("$('.delete-filter').click()")
    wait_for_javascript_to_finish

    expect(page).to have_no_selector('.delete-filter')
  end

  context 'which is their last filter' do
    it 'should delete the saved filters panel' do
      page.execute_script("$('.delete-filter').click()")
      wait_for_javascript_to_finish

      expect(page).to have_no_selector('#saved_searches .panel')
    end
  end
end
