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
#include 'ServiceCalendarHelper'

RSpec.describe "subsidy page", js: true do
  let_there_be_lane
  let_there_be_j
  fake_login_for_each_test
  build_service_request_with_project

  describe "Adding a subsidy" do
    before :each do
      add_visits
      subsidy_map.destroy
      subsidy.destroy
      subsidy_map = create(:subsidy_map, organization_id: program.id, max_dollar_cap: 1000, max_percentage: 50.00, default_percentage: 0.1, instructions: "Lorem ipsum")
      program.update_attribute(:subsidy_map, subsidy_map)
      @max_dollar_cap = subsidy_map.max_dollar_cap.to_f
      @max_percentage = subsidy_map.max_percentage.to_f
      @direct_cost = (sub_service_request.direct_cost_total / 100.00)
      @default_percentage = subsidy_map.default_percentage
      @instructions = subsidy_map.instructions
      visit service_subsidy_service_request_path service_request.id
    end

    it 'should display request cost in the pi contribution field' do
      click_button 'Request a Subsidy'
      wait_for_javascript_to_finish
      pi_field_value = find('#pi_contribution').value
    end

    it 'should adjust the pi contribution if a subsidy percentage is added' do
      click_button 'Request a Subsidy'
      wait_for_javascript_to_finish
      find('#percent_subsidy').set("30\n")
      percent_subsidy = (find('#percent_subsidy').value.to_f) / 100
      wait_for_javascript_to_finish
      adjusted_pi_contribution = @direct_cost - (@direct_cost * percent_subsidy)
      pi_field_value = find('#pi_contribution').value.gsub(/,/, '').gsub('$', '').to_f
      expect(pi_field_value).to eq(adjusted_pi_contribution)
    end

    it 'should adjust the subsidy percent if the pi contribution is changed' do
      click_button 'Request a Subsidy'
      wait_for_javascript_to_finish
      find('#pi_contribution').set("6000\n")
      wait_for_javascript_to_finish

      subsidy_cost = @direct_cost - 6000
      percent_subsidy = ((subsidy_cost / @direct_cost) * 100).round(2)
      percent_field_value = find('#percent_subsidy').value
      expect(percent_field_value).to eq(percent_subsidy.to_s)
    end

    it 'should display instructions if there are any' do
      click_button 'Request a Subsidy'
      expect(page).to have_content("Instructions")
      expect(page).to have_content("Lorem ipsum")
    end

    context 'validating max percent' do

      it 'should hit the validations if the entered percent is higher than the max percent' do
        click_button 'Request a Subsidy'
        wait_for_javascript_to_finish
        find('#percent_subsidy').set("60\n")
        expect(page).to have_content("The Percent Subsidy cannot be greater than the max percent of 50.0")
      end

      it 'should hit the validations if the entered pi contribution results in a percent subsidy greater than the max' do
        click_button 'Request a Subsidy'
        wait_for_javascript_to_finish
        find('#pi_contribution').set("3000\n")
        expect(page).to have_content("The Percent Subsidy cannot be greater than the max percent of 50.0")
      end
    end

    context 'validating max dollar cap' do

      it 'should hit the validations if the entered percent causes subsidy cost to be higher than max dollar cap' do
        program.subsidy_map.update_attribute(:max_dollar_cap, 1000)
        click_button 'Request a Subsidy'
        wait_for_javascript_to_finish
        find('#percent_subsidy').set("45\n")
        expect(page).to have_content("The Subsidy Cost cannot be greater than the max dollar cap of 1000.0")
      end

      it 'should hit the validations if the entered pi contribution causes subsidy cost to be higher than max dollar cap' do
        program.subsidy_map.update_attribute(:max_dollar_cap, 1000)
        click_button 'Request a Subsidy'
        wait_for_javascript_to_finish
        find('#pi_contribution').set("5000\n")
        expect(page).to have_content("The Subsidy Cost cannot be greater than the max dollar cap of 1000.0")
      end
    end
  end
end
