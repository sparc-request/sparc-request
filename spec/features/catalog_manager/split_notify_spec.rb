# Copyright © 2011-2017 MUSC Foundation for Research Development
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
Capybara.ignore_hidden_elements = true

RSpec.describe 'as a user on catalog page', js: true do
  before :each do
    default_catalog_manager_setup
    wait_for_javascript_to_finish
  end

  context "Provider" do
    scenario 'Status Options tab appears' do
      when_user_checks_the_split_notify_checkbox_for_org('South Carolina Clinical and Translational Institute (SCTR)', '#provider_process_ssrs')
      then_the_user_should_see_the_status_options_tab
    end

    scenario 'Status Options tab disappears' do
      when_user_checks_the_split_notify_checkbox_for_org('South Carolina Clinical and Translational Institute (SCTR)', '#provider_process_ssrs')
      when_user_unchecks_the_split_notify_checkbox_for_org('#provider_process_ssrs')
      then_the_user_should_not_see_the_status_options_tab
    end
  end

  context "Program" do
    scenario 'Status Options tab appears' do
      when_user_checks_the_split_notify_checkbox_for_org('Office of Biomedical Informatics', '#program_process_ssrs')
      then_the_user_should_see_the_status_options_tab
    end

    scenario 'Status Options tab disappears' do
      when_user_checks_the_split_notify_checkbox_for_org('Office of Biomedical Informatics', '#program_process_ssrs')
      when_user_unchecks_the_split_notify_checkbox_for_org('#program_process_ssrs')
      then_the_user_should_not_see_the_status_options_tab
    end
  end

  def when_user_unchecks_the_split_notify_checkbox_for_org(selector)
    within '#gen_info' do
      find(selector).click
      wait_for_javascript_to_finish
    end
  end

  def when_user_checks_the_split_notify_checkbox_for_org(org, selector)
    click_link(org)
    within '#gen_info' do
      find(selector).click
      wait_for_javascript_to_finish
    end
  end

  def then_the_user_should_not_see_the_status_options_tab
    expect(page).not_to have_content "Status Options (Use default statuses below or click to create custom service request statuses)"
  end

  def then_the_user_should_see_the_status_options_tab
    expect(page).to have_content "Status Options (Use default statuses below or click to create custom service request statuses)"
  end
end