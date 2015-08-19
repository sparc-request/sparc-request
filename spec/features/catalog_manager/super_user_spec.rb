# Copyright © 2011 MUSC Foundation for Research Development
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

require 'spec_helper'

feature 'super users' do
  background do
    default_catalog_manager_setup
  end

  scenario 'user adds a new super user to institution', :js => true do
    add_super_user

    within "#su_info" do
      page.should have_text("Julia Glenn (glennj@musc.edu)")
    end
  end

  scenario 'user deletes a super user from institution', :js => true do
    add_super_user

    accept_confirm("Are you sure you want to remove this Super User?") do
      within "#su_info" do
        find("img.su_delete").trigger('click')
        wait_for_javascript_to_finish
      end
    end

    a = page.driver.browser.switch_to.alert
    a.text.should eq "Are you sure you want to remove this Super User?"
    a.accept

    within "#su_info" do
      page.should_not have_text("Julia Glenn")
    end
  end
end

def add_super_user
  wait_for_javascript_to_finish
  click_link('Office of Biomedical Informatics')
  within '#user_rights' do
    find('.legend').click
    wait_for_javascript_to_finish
  end
  wait_for_javascript_to_finish
  fill_in "new_su", with: "Julia"
  wait_for_javascript_to_finish
  page.find('a', :text => "Julia Glenn", :visible => true).click()
  wait_for_javascript_to_finish
end
