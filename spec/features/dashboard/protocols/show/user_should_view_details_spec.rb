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

RSpec.describe "User should view details", js: true do
  let_there_be_lane
  fake_login_for_each_test

  context 'clicks view details' do
    scenario 'sees alert stating there are no researching involved' do
      org      = create(:organization)
      protocol = create(:protocol_federally_funded, primary_pi: jug2, type: 'Study')
      sr       = create(:service_request_without_validations, protocol: protocol)
      create(:sub_service_request, service_request: sr, organization: org, protocol: protocol)

      visit dashboard_protocol_path(protocol)
      wait_for_javascript_to_finish

      click_button I18n.t(:dashboard)[:protocols][:documents][:view_study_details]
      wait_for_javascript_to_finish

      within '.modal-content' do
        expect(page).to have_css(
          'div.alert.alert-danger',
          text: 'No Research Types selected'
        )
      end
    end

    scenario 'sees alert even if research types info present' do
      org      = create(:organization)
      protocol = create(:protocol_federally_funded,
                        primary_pi: jug2,
                        type: 'Study'
                       )
      sr       = create(:service_request_without_validations,
                        protocol: protocol)
      create(:sub_service_request,
             service_request: sr,
             organization: org,
             protocol: protocol
            )
      create(:research_types_info,
             protocol: protocol,
             human_subjects: false,
             vertebrate_animals: false,
             investigational_products: false,
             ip_patents: false
            )

      visit dashboard_protocol_path(protocol)
      wait_for_javascript_to_finish

      click_button I18n.t(:dashboard)[:protocols][:documents][:view_study_details]
      wait_for_javascript_to_finish

      within '.modal-content' do
        expect(page).to have_css(
          'div.alert.alert-danger',
          text: 'No Research Types selected'
        )
      end
    end
  end
end
