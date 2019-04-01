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

RSpec.describe 'User manages status options', js: true do
  let_there_be_lane
  fake_login_for_each_test

  before :each do
    @institution        = create(:institution)
    @provider           = create(:provider, :with_subsidy_map, parent_id: @institution.id, process_ssrs: true, use_default_statuses: false)
    create(:catalog_manager, organization_id: @institution.id, identity_id: Identity.where(ldap_uid: 'jug2').first.id)
  end

  context 'and Use Default Statuses option is false' do
    context 'with available status NOT selected' do
      before :each do
        visit catalog_manager_catalog_index_path
        wait_for_javascript_to_finish
        find("#institution-#{@institution.id}").click
        wait_for_javascript_to_finish
        click_link @provider.name
        wait_for_javascript_to_finish

        click_link 'Status Options'
        wait_for_javascript_to_finish
      end

      it 'should add the available status' do
        first('.available-status-checkbox').click
        wait_for_javascript_to_finish
        expect(AvailableStatus.where(organization_id: @provider.id).first.selected).to eq(true)
        expect(first('.available-status-checkbox')).to_not be_disabled
      end

      it 'should not select the disabled available status' do
        first('.available-status-checkbox:disabled').click
        wait_for_javascript_to_finish

        expect(first('.available-status-checkbox:disabled')).to be_disabled
      end
    end

    context 'with available status selected' do
      before :each do
      visit catalog_manager_catalog_index_path
      wait_for_javascript_to_finish
      find("#institution-#{@institution.id}").click
      wait_for_javascript_to_finish
      click_link @provider.name
      wait_for_javascript_to_finish

      click_link 'Status Options'
      wait_for_javascript_to_finish
      first('.available-status-checkbox').click
      wait_for_javascript_to_finish
      end

      it 'should remove the available status' do
        first('.available-status-checkbox').click
        wait_for_javascript_to_finish

        expect(AvailableStatus.where(organization_id: @provider.id).first.selected).to eq(false)
        expect(first('.available-status-checkbox')).to_not be_disabled
      end

    end

  end
end
