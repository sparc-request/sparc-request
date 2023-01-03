# Copyright © 2011-2022 MUSC Foundation for Research Development
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

RSpec.describe "Catalog overlord user merges protocols", js: true do
  let_there_be_lane
  fake_login_for_each_test

  before :each do
    @org       = create(:organization, :process_ssrs, pricing_setup_count: 1)
    @service   = create(:service, organization: @org, pricing_map_count: 1, one_time_fee: true)
    @protocol_master  = create(:study_federally_funded, primary_pi: jug2)
    @protocol_to_merge = create(:study_federally_funded, primary_pi: jug2)
    @sr        = create(:service_request_without_validations, protocol: @protocol_master)
  end

  def click_merge_protocol_button
    visit dashboard_protocol_path(@protocol_master)
    wait_for_javascript_to_finish

    click_link I18n.t('layout.dashboard.navigation.protocol_merge')
    wait_for_javascript_to_finish

    fill_in 'master_protocol_id', with: @protocol_master.id
    fill_in 'merged_protocol_id', with: @protocol_to_merge.id

    click_button 'merge-button'
    find('.swal2-container').find('.swal2-confirm').click

  end

  describe 'Merge Protocol tab' do
    context 'Fulfillment turned on' do
      stub_config('fulfillment_contingent_on_catalog_manager', true)

      it 'should merge protocols without errors' do
        click_merge_protocol_button

        expect(@protocol_master.protocol_merges.count).to eq(1)
        expect(@protocol_master.protocol_merges.pluck(:merged_protocol_id)[0]).to eq(@protocol_to_merge.id)
      end
    end

    context 'Fulfillment turned off' do
      stub_config('fulfillment_contingent_on_catalog_manager', false)

      it 'should merge protocols without errors' do
        click_merge_protocol_button

        expect(@protocol_master.protocol_merges.count).to eq(1)
        expect(@protocol_master.protocol_merges.pluck(:merged_protocol_id)[0]).to eq(@protocol_to_merge.id)
      end
    end

  end


end
