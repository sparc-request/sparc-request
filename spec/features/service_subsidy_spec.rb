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
      subsidy_map = create(:subsidy_map, organization_id: program.id, max_dollar_cap: (sub_service_request.direct_cost_total / 100), max_percentage: 50.00)
      program.update_attribute(:subsidy_map, subsidy_map)
      @direct_cost = (sub_service_request.direct_cost_total / 100.00)
      visit service_subsidy_service_request_path service_request.id
    end

    it 'should display request cost in the pi contribution field' do
      click_button 'Add a Subsidy'
      
      wait_for_javascript_to_finish
      pi_field_value = find('#pi_contribution').value
      expect(@direct_cost.to_s + '0').to eq(pi_field_value)
    end

    it 'should adjust the pi contribution if a subsidy percentage is added' do
      click_button 'Add a Subsidy'
      wait_for_javascript_to_finish
      find('#percent_subsidy').set("30\n")
      wait_for_javascript_to_finish
      new_contribution = @direct_cost - (@direct_cost * 0.3)
      pi_field_value = find('#pi_contribution').value.gsub(/,/, '')
      expect(pi_field_value).to eq('$' + new_contribution.to_s + '0')
    end

    it 'should adjust the subsidy percent if the pi contribution is changed' do
      click_button 'Add a Subsidy'
      wait_for_javascript_to_finish
      new_pi_contribution = (@direct_cost - 1000)
      find('#pi_contribution').set("#{new_pi_contribution.to_s}\n")
      wait_for_javascript_to_finish
      subsidy_cost = @direct_cost - new_pi_contribution
      percent_subsidy = ((subsidy_cost / @direct_cost) * 100).round(2)
      percent_field_value = find('#percent_subsidy').value
      expect(percent_field_value).to eq(percent_subsidy.to_s)
    end

    context 'triggering validations modal' do
      
      it 'should hit the validations if the entered percent is higher than the max percent' do
        click_button 'Add a Subsidy'
        wait_for_javascript_to_finish
        find('#percent_subsidy').set("60\n")
        expect(page).to have_content("The Percent Subsidy cannot be greater than the max percent of 50.0")
      end

      it 'should hit the validations if the entered pi contribution results in a percent subsidy greater than the max' do
        click_button 'Add a Subsidy'
        wait_for_javascript_to_finish
        find('#pi_contribution').set("3000\n")
        expect(page).to have_content("The Percent Subsidy cannot be greater than the max percent of 50.0")
      end
    end
  end
end
