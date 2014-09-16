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

describe "creating a new project ", :js => true do 
  let_there_be_lane
  let_there_be_j
  fake_login_for_each_test
  build_service_request_with_project()

  before :each do
    visit protocol_service_request_path service_request.id

    find('#protocol_Research_Project').click
    wait_for_javascript_to_finish

    find('.new-project').click
    wait_for_javascript_to_finish
  end

  after :each do
    wait_for_javascript_to_finish
  end

  describe "submitting a blank form" do
    it "should show errors when submitting a blank form" do
      find('.continue_button').click
      page.should have_content("Short title can't be blank")
      page.should have_content("Title can't be blank")
      page.should have_content("Funding status can't be blank")
    end
  end

  describe "submitting a filled form" do

    it "should clear errors and submit the form" do
      fill_in "project_short_title", :with => "Bob"
      fill_in "project_title", :with => "Dole"
      select "Funded", :from => "project_funding_status"
      select "Federal", :from => "project_funding_source"

      find('.continue_button').click
      wait_for_javascript_to_finish

      select "Primary PI", :from => "project_role_role"
      click_button "Add Authorized User"
      wait_for_javascript_to_finish

      fill_in "user_search_term", :with => "bjk7"
      wait_for_javascript_to_finish
      page.find('a', :text => "Brian Kelsey (kelsey@musc.edu)", :visible => true).click()
      wait_for_javascript_to_finish
      select "Billing/Business Manager", :from => "project_role_role"
      click_button "Add Authorized User"
      wait_for_javascript_to_finish

      find('.continue_button').click
      wait_for_javascript_to_finish
      
      find(".edit_project_id").should have_value Protocol.last.id.to_s
    end
  end
end

describe "editing a project" do
  let_there_be_lane
  let_there_be_j
  fake_login_for_each_test
  build_service_request()
  build_project()

  before :each do
    visit protocol_service_request_path service_request.id
  end

  describe "editing the short title", :js => true do

    it "should save the short title" do
      find('.edit-project').click
      fill_in "project_short_title", :with => "Patsy"
      find('.continue_button').click
      wait_for_javascript_to_finish
      find('.continue_button').click
      wait_for_javascript_to_finish
      find('.edit-project').click

      find("#project_short_title").should have_value("Patsy")
    end
  end

end
