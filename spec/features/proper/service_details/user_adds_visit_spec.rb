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

RSpec.describe 'User adds an visit to an arm', js: true do
  let_there_be_lane
  fake_login_for_each_test

  before :each do
    org       = create(:organization, :process_ssrs)
    pricing   = create(:pricing_setup, organization: org)
    pppv      = create(:service, organization: org, one_time_fee: false, pricing_map_count: 1)

    @protocol = create(:protocol_federally_funded, primary_pi: jug2)
    sr        = create(:service_request_without_validations, protocol: @protocol)
    ssr       = create(:sub_service_request, service_request: sr, organization: org)
    @pppv_li  = create(:line_item, service_request: sr, sub_service_request: ssr, service: pppv)
    @arm      = create(:arm, protocol: @protocol, subject_count: 10)

    @vg_count = @arm.visit_groups.count

    visit service_details_service_request_path(srid: sr.id)
    wait_for_javascript_to_finish
  end

  it 'should add the visit' do
    click_link I18n.t('visit_groups.new')
    wait_for_javascript_to_finish

    fill_in 'visit_group_name', with: 'No Visitors Allowed'
    fill_in 'visit_group_day', with: @arm.visit_groups.last.day + 5
    bootstrap_select '#visit_group_position', I18n.t('constants.add_as_last')

    click_button I18n.t('actions.submit')
    wait_for_javascript_to_finish

    expect(@arm.reload.visit_groups.count).to eq(@vg_count + 1)
    expect(page).to have_selector('.visit-group td', text: 'No Visitors Allowed')
  end
end
