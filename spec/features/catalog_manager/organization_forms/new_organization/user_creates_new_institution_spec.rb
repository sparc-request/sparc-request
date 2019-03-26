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

RSpec.describe 'User creates new organization', js: true do
  let_there_be_lane
  fake_login_for_each_test

  context 'and the user creates a new institution' do
    before :each do
      visit catalog_manager_catalog_index_path
      wait_for_javascript_to_finish
      click_link 'Create New Institution'
      wait_for_javascript_to_finish

      fill_in 'organization_name', with: 'Test Institution'
      click_button 'Save'
      wait_for_javascript_to_finish

    end

    it 'should add a new institution' do
      expect(Institution.count).to eq(1)
    end

    it 'should show the institution form' do
      expect(page).to have_selector("h3", text: 'Test Institution')
    end

    it 'should disable the new institution after it is created' do
      expect(Institution.where(name: 'Test Institution').first.is_available).to eq(false)
      expect(page).to have_selector('.text-institution.unavailable-org', text: 'Test Institution')
    end
  end
end
