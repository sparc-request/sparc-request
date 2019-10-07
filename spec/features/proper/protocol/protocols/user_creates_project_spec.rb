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

RSpec.describe 'User creates project', js: true do
  let_there_be_lane
  fake_login_for_each_test

  stub_config("use_epic", true)

  before :each do
    org     = create(:organization, name: "Program", process_ssrs: true, pricing_setup_count: 1)
    service = create(:service, name: "Service", abbreviation: "Service", organization: org, pricing_map_count: 1)
    @sr     = create(:service_request_without_validations, status: 'first_draft')
    ssr     = create(:sub_service_request_without_validations, service_request: @sr, organization: org, status: 'first_draft')
              create(:line_item, service_request: @sr, sub_service_request: ssr, service: service)

    visit protocol_service_request_path(srid: @sr.id)
    wait_for_javascript_to_finish
    click_link I18n.t('protocols.form.header.new', protocol_type: Project.model_name.human)
    wait_for_javascript_to_finish
  end

  it 'should create a new project' do
    fill_in 'protocol_short_title', with: 'asd'
    fill_in 'protocol_title', with: 'asd'
    bootstrap_typeahead '#primary_pi', 'Julia'
    bootstrap_select '#protocol_funding_status', 'Funded'
    bootstrap_select '#protocol_funding_source', 'Federal'

    click_button I18n.t('actions.save')
    wait_for_javascript_to_finish

    expect(Project.count).to eq(1)
    expect(@sr.reload.protocol.becomes(Project)).to eq(Project.last)
    expect(page).to have_current_path(protocol_service_request_path(srid: @sr.id))
  end
end
