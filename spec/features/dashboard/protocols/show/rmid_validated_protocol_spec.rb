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
require 'rails_helper'

RSpec.describe 'RMID validated Protocols', js: true do
  let!(:user) do
    create(:identity,
           last_name: "Doe",
           first_name: "John",
           ldap_uid: "johnd",
           email: "johnd@musc.edu",
           password: "p4ssword",
           password_confirmation: "p4ssword",
           approved: true
          )
  end

  fake_login_for_each_test('johnd')

  let!(:study) do
    create(:study_without_validations,
            primary_pi: user,
            rmid_validated: true
          )
  end

  stub_config("research_master_enabled", true)
  
  before :each do
    visit dashboard_protocol_path(study)
    wait_for_javascript_to_finish
  end

  describe 'main page' do
    it 'shows visual cue that the Protocol has been refreshed with RMID data' do
      expect(page).to have_css(
        'h6.text-success',
        text: 'Updated to corresponding Research Master ID Short Title'
      )
      expect(page).to have_css(
        'h6.text-success',
        text: 'Updated to corresponding Research Master ID Title'
      )
    end
  end

  describe 'view details' do
    it 'shows that the Protocol has been refreshed with RMID data' do
      click_button 'View Study Details'
      within '.modal-content' do
        expect(page).to have_css(
          'h6.text-success',
          text: 'Updated to corresponding Research Master ID Short Title'
        )
        expect(page).to have_css(
          'h6.text-success',
          text: 'Updated to corresponding Research Master ID Title'
        )
      end
    end
  end
end

