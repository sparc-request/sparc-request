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

describe 'edit a provider', :js => true do


  before :each do
    default_catalog_manager_setup
    Tag.create(:name => "ctrc")
    click_link('South Carolina Clinical and Translational Institute (SCTR)')
  end


  context 'successfully update an existing provider'  do
    it "should successfully edit and save the provider" do
      # General Information fields
      fill_in 'provider_abbreviation', :with => 'PTP'
      fill_in 'provider_description', :with => 'Description'
      fill_in 'provider_ack_language', :with => 'Language'
      fill_in 'provider_order', :with => '2'
      select('orange', :from => 'provider_css_class')
      check('provider_process_ssrs')
      check('provider_is_available')

      first('#save_button').click
      page.should have_content( 'South Carolina Clinical and Translational Institute (SCTR) saved successfully' )
    end


    context "adding and removing tags" do
      before :each do
        @provider = Organization.where(abbreviation: "SCTR1").first
        wait_for_javascript_to_finish
      end

      it "should list the tags" do
        page.should have_css("#provider_tag_list_ctrc")
      end

      it "should be able to check a tag box" do
        find('#provider_tag_list_ctrc').click
        first("#save_button").click
        page.should have_content( 'South Carolina Clinical and Translational Institute (SCTR) saved successfully' )
        find('#provider_tag_list_ctrc').should be_checked
        @provider.tag_list.should eq(['ctrc'])
      end
    end


    context "editing status options" do
      before :each do
        @provider = Organization.where(abbreviation: "SCTR1").first
        wait_for_javascript_to_finish
        find('#available_statuses_fieldset').click
        sleep 3
      end

      it "should get the default statuses" do
        @provider.get_available_statuses.should eq( {"draft" => "Draft", "submitted" => "Submitted", "get_a_quote" => "Get a Quote", "in_process" => "In Process", "complete" => "Complete", "awaiting_pi_approval" => "Awaiting PI Approval", "on_hold" => "On Hold"} )
      end

      it "should only get the statuses that are checked" do
        find("#provider_available_statuses_attributes_0__destroy").click
        first("#save_button").click
        wait_for_javascript_to_finish
        @provider.get_available_statuses.should eq( {"draft" => "Draft"} )
      end

      it "should not create duplicates if saved twice" do
        find("#provider_available_statuses_attributes_0__destroy").click
        first("#save_button").click
        wait_for_javascript_to_finish
        first("#save_button").click
        wait_for_javascript_to_finish
        @provider.get_available_statuses.should eq( {"draft" => "Draft"} )
      end
    end


    context "viewing user rights section" do
      it "should show user rights section" do
        find('#user_rights').click
        sleep 3
        find('#su_info').should be_visible
      end
    end

    context "pricing section" do
      before :each do
        find('#pricing').click
        sleep 3
      end

      it "should show the pricing section" do
        first('#pricing fieldset').should be_visible
      end
      
      it "should have a functional subsidy section" do
        # Subsidy Information fields
        fill_in 'provider_subsidy_map_attributes_max_percentage', :with => '55.5'
        fill_in 'provider_subsidy_map_attributes_max_dollar_cap', :with => '65'

        first('#save_button').click
        page.should have_content( 'South Carolina Clinical and Translational Institute (SCTR) saved successfully' )
      end
    end
  end
end