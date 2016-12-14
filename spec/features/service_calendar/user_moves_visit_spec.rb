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

RSpec.describe 'User moves a visit', js: true do
  let_there_be_lane

  fake_login_for_each_test

  before :each do
    org       = create(:organization)
    pricing   = create(:pricing_setup, organization: org)
    service   = create(:service, organization: org, one_time_fee: false)

    protocol  = create(:protocol_federally_funded, primary_pi: jug2)
    @sr       = create(:service_request_without_validations, protocol: protocol)
    ssr       = create(:sub_service_request, service_request: @sr, organization: org)
    li        = create(:line_item, service_request: @sr, sub_service_request: ssr, service: service)
  
    @arm      = create(:arm, protocol: protocol, visit_count: 3)
    liv       = create(:line_items_visit, line_item: li, arm: @arm)

    3.times do |n|
      create(:visit, visit_group: create(:visit_group, arm: @arm, day: n), line_items_visit: liv)
    end
  end

  scenario 'and sees the visit has been moved' do
    vgs = @arm.visit_groups.to_a

    visit service_calendar_service_request_path(@sr)
    wait_for_javascript_to_finish

    click_button 'Move Visit'
    wait_for_javascript_to_finish

    bootstrap_select '#visit_group', @arm.visit_groups.first.name
    bootstrap_select '#position', 'add as last'
    click_button 'Save'
    wait_for_javascript_to_finish

    expect(@arm.visit_groups.order(:position).first).to eq(vgs[1])
    expect(@arm.visit_groups.order(:position).second).to eq(vgs[2])
    expect(@arm.visit_groups.order(:position).third).to eq(vgs[0])
  end

  scenario 'and sees the updated calendar view' do
    vgs = @arm.visit_groups.to_a

    visit service_calendar_service_request_path(@sr)
    wait_for_javascript_to_finish

    click_button 'Move Visit'
    wait_for_javascript_to_finish

    bootstrap_select '#visit_group', @arm.visit_groups.first.name
    bootstrap_select '#position', 'add as last'
    click_button 'Save'
    wait_for_javascript_to_finish

    calendar_vgs = all('.visit-group-name')

    expect(calendar_vgs[0].text).to eq(vgs[1].name)
    expect(calendar_vgs[1].text).to eq(vgs[2].name)
    expect(calendar_vgs[2].text).to eq(vgs[0].name)
  end
end
