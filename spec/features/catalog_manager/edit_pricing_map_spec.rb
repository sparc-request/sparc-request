# coding: utf-8
# Copyright © 2011-2016 MUSC Foundation for Research Development
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

RSpec.describe 'edit pricing map', js: true do

  before(:each) do
    default_catalog_manager_setup

    create(:pricing_setup,
            organization_id: Program.first.id,
            display_date: '2000-01-01',
            effective_date: '2000-01-01')
  
    click_link('MUSC Research Data Request (CDW)')
    wait_for_javascript_to_finish
  end

  before(:each, one_time_fee: true) do
    find('#gen_info').click
    wait_for_javascript_to_finish
    check 'service_one_time_fee'
    wait_for_javascript_to_finish

    page.execute_script("$('.ui-accordion-header:nth-of-type(2)').click()")
    wait_for_javascript_to_finish
  end

  before(:each, per_patient: true) do
    find('#gen_info').click
    wait_for_javascript_to_finish
    uncheck 'service_one_time_fee'
    wait_for_javascript_to_finish

    page.execute_script("$('.ui-accordion-header:nth-of-type(2)').click()")
    wait_for_javascript_to_finish
  end

  it 'should save the fields after the return key is hit', per_patient: true do

    within('.ui-accordion > div:nth-of-type(2)') do

      find("input[id$='full_rate']").set("2000\n")
      wait_for_javascript_to_finish
      page.execute_script("$('.ui-accordion-header:nth-of-type(2)').click()")
      wait_for_javascript_to_finish
      expect(find("input[id$='full_rate']")).to have_value("2,000.00")
    end
  end

  describe 'per patient validations', per_patient: true do

    before :each do
      page.execute_script("$('.ui-accordion > div:nth-of-type(2)').click()")
      wait_for_javascript_to_finish
    end

    it "should display the per patient error message if a field is blank" do
      find(".service_unit_type", visible: true).set("")
      wait_for_javascript_to_finish
      expect(page).to have_content("Clinical Quantity Type, Unit Factor, and Units Per Qty Maximum are required on all Per Patient Pricing Maps.")
    end

    it 'should hide the error message if one time fees is clicked' do
      find(".service_unit_type", visible: true).set("")
      wait_for_javascript_to_finish

      expect(page).to have_content("Clinical Quantity Type, Unit Factor, and Units Per Qty Maximum are required on all Per Patient Pricing Maps.")
    end

    it "should hide the error message if that field is filled back in" do
      find(".service_unit_type", visible: true).set("")
      wait_for_javascript_to_finish
      find(".service_unit_type", visible: true).set("Each")
      page.execute_script("$('.service_unit_type:visible').change()") #Shouldn't need this. Argh.
      wait_for_javascript_to_finish
      sleep 1
      expect(page).not_to have_content("Clinical Quantity Type, Unit Factor, and Units Per Qty Maximum are required on all Per Patient Pricing Maps.")
    end
  end

  describe 'one time fee' do

    before :each do
      page.execute_script("$('.ui-accordion > div:nth-of-type(2)').click()")
    end

    it 'should set the one time fee attribute to false when unchecked', per_patient: true do
      service = Service.find_by_abbreviation("CDW")
      wait_for_javascript_to_finish
      find(".service_unit_type", visible: true).set("Each")
      wait_for_javascript_to_finish
      find(".service_unit_minimum", visible: true).click
      wait_for_javascript_to_finish

      first(".save_button").click
      wait_for_javascript_to_finish

      service.reload
      retry_until { expect(service.one_time_fee).to eq(false) }
    end

    context 'validations' do

      it 'should display the one time fee error message if a field is blank', one_time_fee: true do
        find(".otf_quantity_type", visible: true).set("")
        wait_for_javascript_to_finish
        expect(page).to have_content("If the Pricing Map is a one time fee (the box is checked), Quantity Type, Quantity Minimum, Unit Type, and Unit Maximum are required.")
      end

      it 'should hide the error message if that field is filled back in', one_time_fee: true do
        find('.otf_quantity_type', visible: true).set('')
        wait_for_javascript_to_finish

        expect(page).to have_content('If the Pricing Map is a one time fee (the box is checked), Quantity Type, Quantity Minimum, Unit Type, and Unit Maximum are required.')

        find('.otf_quantity_type', visible: true).set('Each')
        page.execute_script("$('.otf_quantity_type:visible').change()") #Shouldn't need this. Argh.
        wait_for_javascript_to_finish

        expect(page).not_to have_content('If the Pricing Map is a one time fee (the box is checked), Quantity Type, Quantity Minimum, Unit Type, and Unit Maximum are required.')
      end

      it 'should hide the error message if the one time fee box is unchecked', one_time_fee: true do
        find('.otf_quantity_type', visible: true).set('')
        wait_for_javascript_to_finish

        expect(page).to have_content("If the Pricing Map is a one time fee (the box is checked), Quantity Type, Quantity Minimum, Unit Type, and Unit Maximum are required.")
      end
    end
  end
end
