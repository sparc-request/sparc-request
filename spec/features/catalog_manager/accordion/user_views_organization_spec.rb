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

RSpec.describe 'User views an organization', js: true do
  let_there_be_lane
  fake_login_for_each_test

  before :each do
    @institution  = create(:institution, :with_subsidy_map)
    @provider     = create(:provider, :with_subsidy_map, parent: @institution)
    @program      = create(:program, :with_subsidy_map, parent: @provider)
    @core         = create(:core, :with_subsidy_map, parent: @program)
    create(:catalog_manager, organization: @institution, identity: jug2)

    visit catalog_manager_catalog_index_path
    wait_for_javascript_to_finish
  end

  context 'Institution' do
    before :each do
      click_link @institution.name
      wait_for_javascript_to_finish
    end

    it 'should show the institution form' do
      expect(page).to have_selector("h3", text: @institution.name)
    end
  end

  context 'Provider' do
    before :each do
      find("#institution-#{@institution.id} .glyphicon").click
      click_link @provider.name
      wait_for_javascript_to_finish
    end

    it 'should show the provider form' do
      expect(page).to have_selector("h3", text: @provider.name)
    end
  end

  context 'Program' do
    before :each do
      find("#institution-#{@institution.id} .glyphicon").click
      find("#provider-#{@provider.id} .glyphicon").click
      click_link @program.name
      wait_for_javascript_to_finish
    end

    it 'should show the program form' do
      expect(page).to have_selector("h3", text: @program.name)
    end
  end

  context 'Core' do
    before :each do
      find("#institution-#{@institution.id} .glyphicon").click
      find("#provider-#{@provider.id} .glyphicon").click
      find("#program-#{@program.id} .glyphicon").click
      wait_for_javascript_to_finish
      click_link @core.name
      wait_for_javascript_to_finish
    end

    it 'should show the core form' do
      expect(page).to have_selector("h3", text: @core.name)
    end
  end
end
