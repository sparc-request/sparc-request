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

RSpec.describe 'User edits study', js: true do
  let_there_be_lane
  fake_login_for_each_test
  build_study_phases
  
  stub_config("research_master_enabled", false)

  before :each do
    institution = create(:institution, name: "Institution")
    provider    = create(:provider, name: "Provider", parent: institution)
    program     = create(:program, name: "Program", parent: provider, process_ssrs: true)
    service     = create(:service, name: "Service", abbreviation: "Service", organization: program)
    @protocol   = create(:protocol_federally_funded, type: 'Study', primary_pi: jug2)
    @sr         = create(:service_request_without_validations, status: 'first_draft', protocol: @protocol)
    ssr         = create(:sub_service_request_without_validations, service_request: @sr, organization: program, status: 'first_draft')
                  create(:line_item, service_request: @sr, sub_service_request: ssr, service: service)
    StudyTypeQuestionGroup.create(active: 1)

    allow_any_instance_of(Protocol).to receive(:rmid_server_status).and_return(false)
  end

  context 'selects multiple study phases' do
    before :each do
      page = Dashboard::Protocols::ShowPage.new
      page.load(id: @protocol.id)
      wait_for_javascript_to_finish
      page.protocol_summary.edit_study_info_button.click
      find('.human-subjects').click
      wait_for_javascript_to_finish

      find('[data-id="protocol_study_phase_ids"]').click
      first('.dropdown-menu.open span.text', text: "IV").click
    end

    it 'and sees updated study phases (IV)' do
      find('body').click # Click away
      click_button 'Save'
      wait_for_javascript_to_finish
      expect(@protocol.reload.study_phase_ids).to eq([study_phase_IV.id])
    end

    it 'and sees updated study phases (O,I,IV)' do
      first('.dropdown-menu.open span.text', text: "I").click
      first('.dropdown-menu.open span.text', text: "O").click
      find('body').click # Click away
      click_button 'Save'
      wait_for_javascript_to_finish
      expect(@protocol.reload.study_phase_ids).to eq([study_phase_O.id, study_phase_I.id, study_phase_IV.id])
    end

    it 'and sees updated study phases (O,I,IIa,IV)' do
      first('.dropdown-menu.open span.text', text: "I").click
      first('.dropdown-menu.open span.text', text: "O").click
      first('.dropdown-menu.open span.text', text: "IIa").click
      find('body').click # Click away
      click_button 'Save'
      wait_for_javascript_to_finish
      expect(@protocol.reload.study_phase_ids).to eq([study_phase_O.id, study_phase_I.id, study_phase_IIa.id, study_phase_IV.id])
    end
  end
end
