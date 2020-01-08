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
# Line Item notes are for OTF
RSpec.describe 'User adds a line items visit note', js: true do
  let_there_be_lane
  fake_login_for_each_test

  before :each do
    org       = create(:organization, :process_ssrs)
    pricing   = create(:pricing_setup, organization: org)
    otf       = create(:service, organization: org, one_time_fee: true, pricing_map_count: 1)
    otf.pricing_maps.first.update_attributes(otf_unit_type: 'total')

    protocol  = create(:protocol_federally_funded, primary_pi: jug2)
    sr        = create(:service_request_without_validations, protocol: protocol)
    ssr       = create(:sub_service_request, service_request: sr, organization: org)
    @otf_li   = create(:line_item, service_request: sr, sub_service_request: ssr, service: otf, units_per_quantity: 1, quantity: 1)

    visit service_details_service_request_path(srid: sr.id)
    wait_for_javascript_to_finish
  end

  it 'should add the note' do
    first('td.notes a').click
    wait_for_javascript_to_finish

    fill_in 'note_body', with: 'This is super important'

    click_button I18n.t('notes.add')
    wait_for_javascript_to_finish

    expect(@otf_li.reload.notes.count).to eq(1)
  end
end
