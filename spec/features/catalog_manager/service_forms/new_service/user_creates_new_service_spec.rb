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

RSpec.describe 'User creates new service', js: true do
  let_there_be_lane
  fake_login_for_each_test

  before :each do
    @institution = create(:institution)
    @provider    = create(:provider, parent_id: @institution.id)
    @program     = create(:program, parent_id: @provider.id)
    create(:catalog_manager, organization_id: @institution.id, identity_id: Identity.where(ldap_uid: 'jug2').first.id)
  end

  context 'and the user completes the form' do
    before :each do
      visit catalog_manager_catalog_index_path
      wait_for_javascript_to_finish
      find("#institution-#{@institution.id} .glyphicon").click
      find("#provider-#{@provider.id} .glyphicon").click
      find("#program-#{@program.id} .glyphicon").click
      wait_for_javascript_to_finish

      click_link 'Create New Service'
      wait_for_javascript_to_finish

      find('.modal-body').fill_in 'service_name', with: 'Test Service'
      choose('service_one_time_fee_true', allow_label_click: true)
      find('.modal-footer').click_button 'Save'
      wait_for_javascript_to_finish
    end

    it 'should add a one time fee service and show the form and disable the new service after creation' do
      expect(Service.where(one_time_fee: true).count).to eq(1)
      expect(Service.where(name: 'Test Service').first.is_available).to eq(false)
      expect(page).to have_selector("h3", text: 'Test Service')
    end

    it 'should throw error if One Time Fee / Clinical is not selected' do
      find("#institution-#{@institution.id} .glyphicon").click
      find("#provider-#{@provider.id} .glyphicon").click
      find("#program-#{@program.id} .glyphicon").click
      wait_for_javascript_to_finish
      click_link 'Create New Service'
      wait_for_javascript_to_finish

      find('.modal-body').fill_in 'service_name', with: 'Test Service'
      find('.modal-footer').click_button 'Save'
      wait_for_javascript_to_finish

      expect(page).to have_content('You must choose either One Time Fee, or Clinical Service.')
    end
  end
end

