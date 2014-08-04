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

describe 'Full service request' do

  # before :each do
  #   create_default_data
  #   create_ctrc_data
  # end
  # let_there_be_j
  let_there_be_lane
  let_there_be_j
  build_service_request_with_project

  context "without any existing arms" do

    before :each do
      project.arms.each {|x| x.destroy}
    end

    it "should create a complete service request", :js => true do
      ### CATALOG PAGE ###
      visit root_path

      click_link("South Carolina Clinical and Translational Institute (SCTR)")
      wait_for_javascript_to_finish
      find(".provider-name").should have_text("South Carolina Clinical and Translational Institute (SCTR)")

      click_link("Office of Biomedical Informatics")
      find("#service-1").click() # Add service 'Human Subject Review' to cart
      wait_for_javascript_to_finish

      # # TODO: Switch this to a search
      find("#service-2").click()
      wait_for_javascript_to_finish

      find(".submit-request-button").click # Submit to begin services

      click_link "Outside Users Click Here"
      ### LOGIN PAGE ###
      fill_in("identity_ldap_uid", :with => 'jug2')
      fill_in("identity_password", :with => 'p4ssword')
      find(".devise_submit_button").click
    end
  end
end