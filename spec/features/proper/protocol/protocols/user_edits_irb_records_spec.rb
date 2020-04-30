# Copyright © 2011-2020 MUSC Foundation for Research Development
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

RSpec.describe 'User wants to edit a Study with IRB Records', js: true do
  let_there_be_lane
  fake_login_for_each_test
  build_study_type_question_groups
  build_study_type_questions

  before :each do
    org       = create(:organization, name: "Program", process_ssrs: true, pricing_setup_count: 1)
    service   = create(:service, name: "Service", abbreviation: "Service", organization: org, pricing_map_count: 1)
    @protocol = create(:study_federally_funded, primary_pi: jug2, human_subjects: true, with_irb: true)
    @sr       = create(:service_request_without_validations, status: 'first_draft')
    ssr       = create(:sub_service_request_without_validations, service_request: @sr, organization: org, status: 'first_draft')
                create(:line_item, service_request: @sr, sub_service_request: ssr, service: service)
    @irb      = @protocol.irb_records.first

    visit edit_protocol_path(@protocol, srid: @sr.id)
  end

  it 'should update the IRB Records' do
    find('.delete-irb').click
    wait_for_javascript_to_finish

    find('#newIrbRecord').click
    wait_for_javascript_to_finish

    fill_in 'irb_record_pro_number', with: '2222222222'
    click_button I18n.t('actions.submit')
    wait_for_javascript_to_finish

    click_button I18n.t('actions.save')
    wait_for_javascript_to_finish

    expect(@protocol.irb_records.count).to eq(1)
    irb = @protocol.irb_records.first
    expect(irb.pro_number).to eq('2222222222')
  end
end
