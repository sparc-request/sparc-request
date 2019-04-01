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

RSpec.describe 'User edits Service Epic Interface', js: true do
  let_there_be_lane
  fake_login_for_each_test

  before :each do
    @institution = create(:institution)
    @provider    = create(:provider, parent_id: @institution.id)
    @program     = create(:program, parent_id: @provider.id)
    @service     = create(:service, organization: @program, tag_list: 'epic')
    create(:catalog_manager, organization_id: @institution.id, identity_id: Identity.where(ldap_uid: 'jug2').first.id)
  end

  context 'on a Service' do
    context 'and the user edits the epic interface' do
      before :each do
        visit catalog_manager_catalog_index_path
        wait_for_javascript_to_finish
        find("#institution-#{@institution.id} .glyphicon").click
        find("#provider-#{@provider.id} .glyphicon").click
        find("#program-#{@program.id} .glyphicon").click
        wait_for_javascript_to_finish
        find('a span', text: @service.name).click
        wait_for_javascript_to_finish

        click_link 'Epic Interface'
        wait_for_javascript_to_finish
      end

      it 'should edit the eap id' do
        fill_in 'service_eap_id', with: "1000"
        click_button 'Save'
        wait_for_javascript_to_finish

        @service.reload
        expect(@service.eap_id).to eq("1000")
      end

      it 'should edit the cpt code' do
        fill_in 'service_cpt_code', with: "2000"
        click_button 'Save'
        wait_for_javascript_to_finish

        @service.reload
        expect(@service.cpt_code).to eq("2000")
      end

      it 'should edit the charge code' do
        fill_in 'service_charge_code', with: "3000"
        click_button 'Save'
        wait_for_javascript_to_finish

        @service.reload
        expect(@service.charge_code).to eq("3000")
      end

      it 'should edit the revenue code' do
        fill_in 'service_revenue_code', with: "4000"
        click_button 'Save'
        wait_for_javascript_to_finish

        @service.reload
        expect(@service.revenue_code).to eq("4000")
      end

      it 'should edit the order code' do
        fill_in 'service_order_code', with: "5000"
        click_button 'Save'
        wait_for_javascript_to_finish

        @service.reload
        expect(@service.order_code).to eq("5000")
      end

      it 'should toggle Send to Epic' do
        find('#epic div.toggle.btn').click
        click_button 'Save'
        wait_for_javascript_to_finish

        @service.reload
        expect(@service.send_to_epic).to eq(true)
      end

    end
  end

end
