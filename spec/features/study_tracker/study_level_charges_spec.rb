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

describe "study level charges", js: true do
  let_there_be_lane
  let_there_be_j
  fake_login_for_each_test
  build_service_request_with_project()

  before :each do
    add_visits
    sub_service_request.update_attributes(in_work_fulfillment: true)
  end

  after :each do
    wait_for_javascript_to_finish
  end

  def save_form 
    within('p.buttons', visible: true) do
      click_button("Save")
      wait_for_javascript_to_finish
    end
  end

  def add_fulfillment
    find('.add_nested_fields', visible: true).click
    wait_for_javascript_to_finish
  end

  describe "entering fulfillment information" do

    before(:each) do
      visit study_tracker_sub_service_request_path(sub_service_request.id)
      click_link "Study Level Charges"
      add_fulfillment
    end

    it 'should successfully add a fulfillment' do
      page.should have_content('Date')
    end

    it 'should set and save the fields' do
  
      find('.fulfillment_date').click
      sleep 2
      first('a.ui-state-default.ui-state-highlight').click
      sleep 2
      find('.fulfillment_quantity').set(1)
      find('.fulfillment_quantity_type').select("Sample")
      find('.fulfillment_unit_quantity').set(1)
      find('.fulfillment_unit_type').select("Aliquot")
      find('.fulfillment_notes').set("You're darn tootin'!")

      save_form

      otf = sub_service_request.one_time_fee_line_items.first
      fulfillment = otf.fulfillments.first
      fulfillment.quantity.should eq(1)
      fulfillment.quantity_type.should eq("Sample")
      fulfillment.unit_quantity.should eq(1)
      fulfillment.unit_type.should eq("Aliquot")
      fulfillment.notes.should eq("You're darn tootin'!")
    end

    context "validations" do

      it "should not allow the fulfillment to save if all fields are left blank" do
        save_form

        page.should have_content("Date and quantity are required fields and must be entered with appropriate values")
      end

      it "should validate for the presence of the date" do
        find('.fulfillment_quantity').set(1)
        find('.fulfillment_unit_quantity').set(1)

        save_form

        page.should have_content("Date and quantity are required fields and must be entered with appropriate values")
      end

      it "should validate for a quantity" do
        find('.fulfillment_date').click
        sleep 2
        first('a.ui-state-default.ui-state-highlight').click
        sleep 2
        find('.fulfillment_unit_quantity').set(1)

        save_form

        page.should have_content("Date and quantity are required fields and must be entered with appropriate values")
      end

      it "should not require that the notes field is filled in" do
        find('.fulfillment_date').click
        sleep 2
        first('a.ui-state-default.ui-state-highlight').click
        sleep 2
        find('.fulfillment_quantity').set(1)
        find('.fulfillment_unit_quantity').set(1)

        save_form

        page.should_not have_content("Date and quantity are required fields and must be entered with appropriate values")
      end

      it "should hide the fulfilment if the fulfillment header is clicked" do
        find('.fulfillment_header').click
        wait_for_javascript_to_finish
        page.should_not have_selector('.fulfillment_date')
      end
    end
  end
end