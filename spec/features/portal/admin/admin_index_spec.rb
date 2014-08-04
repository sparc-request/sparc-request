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

describe "admin index page", :js => true do
  let_there_be_lane
  let_there_be_j
  fake_login_for_each_test
  build_service_request_with_study

  before :each do
    add_visits
  end

  context "with service provider rights" do
    before :each do
      visit portal_admin_index_path
    end

    it "should allow access to the admin page if the user is a service provider" do
      page.should have_content 'Dashboard'
      page.should have_content 'Welcome'
    end

    it "should have a service request listed in draft status" do
      page.should have_content 'Draft (1)'
    end

    it "should show sub service requests for the status I have selected" do
      select('Draft (1)', :from => 'service_request_workflow_states')
      wait_for_javascript_to_finish
      page.should have_content(service_request.protocol.short_title)
    end

    describe "search functionality" do

      it "should search by protocol id" do
        find('.search-all-service-requests').set("#{service_request.protocol.id}")
        find('.ui-autocomplete').should have_content("#{service_request.protocol.id}")
      end

      it "should search by service requester" do
        find('.search-all-service-requests').set('glenn')
        find('.ui-autocomplete').should have_content('Julia Glenn')
      end

      it "should search by PI" do
        new_pi = FactoryGirl.create(:identity, :last_name => 'Ketchum', :first_name => 'Ash')
        FactoryGirl.create(:project_role, :protocol_id => service_request.protocol_id, :identity_id => new_pi.id, :role => 'primary-pi')
        ProjectRole.find_by_identity_id(jug2.id).update_attribute(:role, 'co-investigator')
        visit portal_admin_index_path
        find('.search-all-service-requests').set('ketchum')
        find('.ui-autocomplete').should have_content('Ash Ketchum')
      end

      it "should filter sub service requests if I select a search result" do
        find('.search-all-service-requests').set('glenn')
        wait_for_javascript_to_finish
        find('ul.ui-autocomplete a').click
        wait_for_javascript_to_finish
        page.should have_content(service_request.protocol.short_title)
      end

    end

    describe "opening a sub service request" do

      before :each do
        select('Draft (1)', :from => 'service_request_workflow_states')
        wait_for_javascript_to_finish
      end

      it "should not open if I click an expandable field" do
        find('ul.services_first li').click()
        wait_for_javascript_to_finish
        page.should_not have_content('Send Notifications')
      end

      it "should open a sub service request if I click that sub service request" do
        find('td', :text => "#{service_request.protocol.id}-").click
        wait_for_javascript_to_finish
        page.should have_content('Send Notifications')
      end

    end

  end

  context "without service provider rights" do

    before :each do
      service_provider.destroy
    end

    context "with no rights" do
      it "should redirect to the root path" do
        visit portal_admin_index_path
        wait_for_javascript_to_finish
        page.should have_content('Welcome to the SPARC Request Services Catalog')
      end
    end

    context "with super user rights" do
      it "should allow access to the admin page if the user is a super user" do
        FactoryGirl.create(:super_user, identity_id: jug2.id, organization_id: provider.id)
        visit portal_admin_index_path
        page.should have_content 'Dashboard'
        page.should have_content 'Welcome'
      end
    end

  end

end
