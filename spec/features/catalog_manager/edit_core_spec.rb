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

describe 'edit a core', :js => true do

  before :each do
    default_catalog_manager_setup
    Tag.create(:name => "ctrc")
    Tag.create(:name => "clinical work fulfillment")
    click_link('Clinical Data Warehouse')
    wait_for_javascript_to_finish
  end

  context 'successfully update an existing core' do
    it "should successfully edit and save the core" do
      # General Information fields
      fill_in 'core_abbreviation', :with => 'PTP'
      fill_in 'core_order', :with => '2'

      first("#save_button").click
      page.should have_content('Clinical Data Warehouse')
    end

    context "adding and removing tags" do
      before :each do
        @core = Organization.where(abbreviation: "Clinical Data Warehouse").first
        wait_for_javascript_to_finish
      end

      it "should list the tags" do
        page.should have_css('#core_tag_list_ctrc')
      end

      it "should be able to check a tag box" do
        find('#core_tag_list_ctrc').click
        first('#save_button').click
        expect(page).to have_content('Clinical Data Warehouse')
        expect(find('#core_tag_list_ctrc')).to be_checked
        wait_for_javascript_to_finish
        expect(@core.tag_list).to eq(['ctrc'])
      end
    end

    context "editing status options" do
      before :each do
        @core = Organization.where(abbreviation: "Clinical Data Warehouse").first
        wait_for_javascript_to_finish
        find('#available_statuses_fieldset').click
        sleep 3
      end

      it "should get the default statuses" do
        @core.get_available_statuses.should eq( {"draft" => "Draft", "submitted" => "Submitted", "get_a_quote" => "Get a Quote", "in_process" => "In Process", "complete" => "Complete", "awaiting_pi_approval" => "Awaiting Requester Response", "on_hold" => "On Hold"} )
      end

      it "should only get the statuses that are checked" do
        find("#core_available_statuses_attributes_0__destroy").click
        first("#save_button").click
        wait_for_javascript_to_finish
        @core.get_available_statuses.should eq( {"draft" => "Draft"} )
      end

      it "should not create duplicates if saved twice" do
        find("#core_available_statuses_attributes_0__destroy").click
        first("#save_button").click
        wait_for_javascript_to_finish
        first("#save_button").click
        wait_for_javascript_to_finish
        @core.get_available_statuses.should eq( {"draft" => "Draft"} )
      end
    end

    context "viewing user rights section" do
      it "should show user rights section" do
        find('#user_rights').click
        sleep 3
        find('#su_info').should be_visible
      end
    end

    context "viewing cwf section" do
      it "should not display cwf by default" do
        page.should_not have_css('#cwf_fieldset')
      end

      it "should display cwf if tagged with cwf" do
        first('#core_tag_list_clinical_work_fulfillment').click
        first("#save_button").click
        wait_for_javascript_to_finish
        page.should have_content('Clinical Data Warehouse saved successfully')
        click_link('Clinical Data Warehouse')
        wait_for_javascript_to_finish

        find('#cwf_fieldset').should be_visible
        find('#cwf_fieldset').click
        sleep 3
        first('#cwf_fieldset fieldset').should be_visible
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
        fill_in 'core_subsidy_map_attributes_max_percentage', :with => '55.5'
        fill_in 'core_subsidy_map_attributes_max_dollar_cap', :with => '65'

        first("#save_button").click
        page.should have_content('Clinical Data Warehouse saved successfully')
      end
    end
  end
end
