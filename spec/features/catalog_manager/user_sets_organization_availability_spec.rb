# Copyright © 2011-2016 MUSC Foundation for Research Development~
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

RSpec.feature 'User sets organization availability', js: true do

  before(:each) do
    create_default_data
    @provider_available = Provider.first()
    @core_unavailable = Core.first()
    @core_unavailable.update_attributes(is_available: false)
    login_as(Identity.find_by_ldap_uid('jug2@musc.edu'))
  end

  scenario 'to unavailable in show available' do
    given_i_am_viewing_catalog_manager
    when_i_set_the_organization_availability_to_unavailable
    then_i_should_not_see_the_organization
  end

  scenario 'to available in show all' do
    given_i_am_viewing_catalog_manager
    when_i_view_all_organizations
    and_then_i_set_the_organization_availability_to_available
    and_i_am_viewing_only_available_organizations
    then_i_should_see_the_organization
  end

  scenario 'to unavailable in show all' do
    given_i_am_viewing_catalog_manager
    when_i_view_all_organizations
    and_then_i_set_the_organization_availability_to_unavailable
    then_i_should_see_the_organization_as_visually_distinguished 
  end

  def given_i_am_viewing_catalog_manager
    visit catalog_manager_root_path
    page.execute_script("$('#catalog').find('.jstree-closed').attr('class', 'jstree-open');")
    wait_for_javascript_to_finish
  end

  def when_i_set_the_organization_availability_to_unavailable
    first("#PROVIDER#{@provider_available.id} a").click
    find('#provider_is_available').click
    first('#save_button').click
    wait_for_javascript_to_finish
  end

  def and_then_i_set_the_organization_availability_to_available
    page.execute_script("$('#catalog').find('.jstree-closed').attr('class', 'jstree-open');")
    first("#CORE#{@core_unavailable.id} a").click
    wait_for_javascript_to_finish
    find('#core_is_available').click
    first('#save_button').click
    wait_for_javascript_to_finish
  end

  def and_then_i_set_the_organization_availability_to_unavailable
    page.execute_script("$('#catalog').find('.jstree-closed').attr('class', 'jstree-open');")
    first("#PROVIDER#{@provider_available.id} a").click
    wait_for_javascript_to_finish
    find('#provider_is_available').click
    first('#save_button').click
    wait_for_javascript_to_finish
  end

  def then_i_should_see_the_organization_as_visually_distinguished
    expect(page).to have_css("#PROVIDER#{@provider_available.id}.entity_visibility")
  end

  def and_i_am_viewing_only_available_organizations
    find('.unavailable_button').click
    wait_for_javascript_to_finish
    page.execute_script("$('#catalog').find('.jstree-closed').attr('class', 'jstree-open');")
    page.execute_script("$('#catalog').find('.jstree-closed').attr('class', 'jstree-open');")
    wait_for_javascript_to_finish
  end

  def when_i_view_all_organizations
    find('.unavailable_button').click
    wait_for_javascript_to_finish
    page.execute_script("$('#catalog').find('.jstree-closed').attr('class', 'jstree-open');")
    page.execute_script("$('#catalog').find('.jstree-closed').attr('class', 'jstree-open');")
    wait_for_javascript_to_finish
  end

  def then_i_should_not_see_the_organization
    expect(page).to_not have_css("#PROVIDER#{@provider_available.id}")
  end

  def then_i_should_see_the_organization
    expect(page).to have_css("#CORE#{@core_unavailable.id}")
  end
end
