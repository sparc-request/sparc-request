# Copyright © 2011-2022 MUSC Foundation for Research Development
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

RSpec.describe 'User moves visit within an arm', js: true do
  let_there_be_lane
  fake_login_for_each_test

  before :each do
    org       = create(:organization, :process_ssrs)
    pricing   = create(:pricing_setup, organization: org)
    pppv      = create(:service, organization: org, one_time_fee: false, pricing_map_count: 1)

    @protocol = create(:protocol_federally_funded, primary_pi: jug2)
    @sr        = create(:service_request_without_validations, protocol: @protocol)
    @ssr       = create(:sub_service_request, service_request: @sr, organization: org)
    @pppv_li  = create(:line_item, service_request: @sr, sub_service_request: @ssr, service: pppv)
    @arm      = create(:arm, protocol: @protocol, subject_count: 10)

    @visit_group1 = @arm.visit_groups.first
    @visit_group2 = create(:visit_group, arm_id: @arm.id, name: 'Visit 2', position: 2, day: 5)
    @visit_group3 = create(:visit_group, arm_id: @arm.id, name: 'Visit 3', position: 3, day: 10)

    visit service_details_service_request_path(srid: @sr.id)
    wait_for_javascript_to_finish
  end

  it 'should place consecutive visits in the correct order' do

    first(".visit-group-#{@visit_group3.id} a").click;
    wait_for_javascript_to_finish

    fill_in 'visit_group_day', with: 0
    bootstrap_select '#visit_group_position', 1

    click_button I18n.t('actions.submit')
    wait_for_javascript_to_finish

    expect(@visit_group3.reload.position).to eq(1)
    expect(@visit_group1.reload.position).to eq(2)
    expect(@visit_group2.reload.position).to eq(3)
  end

  it 'should calculate min and max values correctly' do

    first(".visit-group-#{@visit_group3.id} a").click;
    wait_for_javascript_to_finish

    bootstrap_select '#visit_group_position', 2

    min = @visit_group1.day + 1
    max = @visit_group2.day - 1
    expect(page).to have_content('Min: ' + min.to_s + ' Max: ' + max.to_s)
  end

  it 'should not move the visit if the position is not changed' do

    first(".visit-group-#{@visit_group3.id} a").click
    wait_for_javascript_to_finish

    fill_in 'visit_group_name', with: 'Last Visit'
    fill_in 'visit_group_window_before', with: 1
    fill_in 'visit_group_window_after', with: 1

    click_button I18n.t('actions.submit')
    wait_for_javascript_to_finish

    expect(@visit_group3.reload.position).to eq(3)
  end

  it 'should throw an error if the same day is added again' do

    first(".visit-group-#{@visit_group3.id} a").click;
    wait_for_javascript_to_finish

    fill_in 'visit_group_day', with: 5

    click_button I18n.t('actions.submit')
    wait_for_javascript_to_finish

    expect(page).to have_content('Must be in order')
  end

  it 'should increment consecutive visits correctly when moved between two consecutive visits' do
    @visit_group2.update_attributes(day: 2)

    first(".visit-group-#{@visit_group3.id} a").click
    wait_for_javascript_to_finish

    bootstrap_select '#visit_group_position', 2
    fill_in 'visit_group_day', with: 2

    click_button I18n.t('actions.submit')
    wait_for_javascript_to_finish

    @visit_group3 = VisitGroup.where(name: 'Visit 3').first

    expect(@visit_group3.position).to eq(2)
    expect(@visit_group2.reload.position).to eq(3)

  end

  it 'should set the day correctly for consecutive visits when moved between two consecutive visits' do
    @visit_group2.update_attributes(day: 2)
    @visit_group3.update_attributes(day: 3)
    @visit_group4 = create(:visit_group, arm_id: @arm.id, name: 'Visit 4', position: 4, day: 4)

    visit service_details_service_request_path(srid: @sr.id)
    wait_for_javascript_to_finish

    first(".visit-group-#{@visit_group4.id} a").click
    wait_for_javascript_to_finish

    bootstrap_select '#visit_group_position', 2

    click_button I18n.t('actions.submit')
    wait_for_javascript_to_finish

    expect(@visit_group4.reload.day).to eq(@visit_group2.day)
    expect(@visit_group2.reload.day).to eq(@visit_group4.reload.day + 1)
    expect(@visit_group3.reload.day).to eq(@visit_group2.reload.day + 1)

  end

end
