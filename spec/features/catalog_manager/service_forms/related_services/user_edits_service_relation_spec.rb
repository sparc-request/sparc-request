# Copyright © 2011-2018 MUSC Foundation for Research Development
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

RSpec.describe 'User edits a related service', js: true do
  let_there_be_lane
  fake_login_for_each_test

  before :each do
    @institution  = create(:institution)
    @provider     = create(:provider, parent: @institution)
    @program      = create(:program, parent: @provider)
    @service      = create(:service, organization: @program)
    @rel_serv     = create(:service, organization: @program)
    @relation     = create(:service_relation, service: @service, related_service: @rel_serv, required: true, linked_quantity: false)
    create(:catalog_manager, organization: @institution, identity: jug2)

    visit catalog_manager_catalog_index_path
    wait_for_javascript_to_finish
    find("#institution-#{@institution.id} .glyphicon").click
    find("#provider-#{@provider.id} .glyphicon").click
    find("#program-#{@program.id} .glyphicon").click
    wait_for_javascript_to_finish
    expect(page).to have_selector('a span', text: @service.name)
    find('a span', text: @service.name).click
    wait_for_javascript_to_finish

    click_link I18n.t(:catalog_manager)[:organization_form][:related_services]
  end

  context 'required field' do
    it 'should change the required field' do
      first('.required').click
      wait_for_javascript_to_finish

      expect(@relation.reload.required).to eq(false)
    end
  end

  context 'linked_quantity field' do
    it 'should change the linked_quantity field' do
      first('.linked_quantity').click
      wait_for_javascript_to_finish

      expect(@relation.reload.linked_quantity).to eq(true)
    end
  end

  context 'quantity_total field' do
    it 'should change the quantity_total field' do
      first('.linked_quantity').click
      wait_for_javascript_to_finish

      fill_in "linked_quantity_total_#{@relation.id}", with: 100
      first('label').click
      wait_for_javascript_to_finish

      expect(@relation.reload.linked_quantity_total).to eq(100)
    end
  end
end
