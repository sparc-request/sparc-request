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

describe "payments", js: true do
  let_there_be_lane
  let_there_be_j
  fake_login_for_each_test
  build_service_request_with_project()

  before :each do
    create_visits    
    sub_service_request.update_attributes(in_work_fulfillment: true)
  end

  after :each do
    wait_for_javascript_to_finish
  end

  describe "Generate research project summary report" do
    before(:each) do
      visit study_tracker_sub_service_request_path(sub_service_request.id)
      click_link "billing-tab"
    end

    it "should create a new report" do
      sub_service_request.reports.size.should eq(0)
      
      click_link "Project summary report"
      wait_for_javascript_to_finish

      page.execute_script %Q{ $('a.ui-datepicker-prev').trigger("click") } # go back one month
      wait_for_javascript_to_finish
      page.execute_script %Q{ $("td.ui-datepicker-week-end:first").trigger("click") } # click on day
      wait_for_javascript_to_finish
      find("#rps_end_date").click
      wait_for_javascript_to_finish
      page.execute_script %Q{ $("td.ui-datepicker-week-end:first").trigger("click") } # click on day
      wait_for_javascript_to_finish

      find("#rps_continue").click
      wait_for_javascript_to_finish

      within('#billings_list') do
        page.should have_content("Research Project Summary Report")
      end

      sub_service_request.reload 
      sub_service_request.reports.size.should eq(1)
    end
  end

  describe "Setting routing for Sub Service Request" do
    before(:each) do
      visit study_tracker_sub_service_request_path(sub_service_request.id)
      click_link "billing-tab"
    end

    it "should set the routing for a sub service request" do
      sub_service_request.routing.should be_nil

      fill_in 'ssr_routing', :with => 'Andrew'
      click_link 'ssr_save'
      wait_for_javascript_to_finish

      sub_service_request.reload
      sub_service_request.routing.should eq('Andrew')
    end
  end
end
