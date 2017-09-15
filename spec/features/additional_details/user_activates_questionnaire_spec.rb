# Copyright © 2011-2017 MUSC Foundation for Research Development~
# All rights reserved.~

# Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:~

# 1. Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.~

# 2. Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following~
# disclaimer in the documentation and/or other materials provided with the distribution.~

# 3. Neither the name of the copyright holder nor the names of its contributors may be used to endorse or promote products~
# derived from this software without specific prior written permission.~

# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING,~
# BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT~
# SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL~
# DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS~
# INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR~
# TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.~

require 'rails_helper'

RSpec.describe 'User has multiple questionnaires that can be activated', js: true do

  let_there_be_lane
  fake_login_for_each_test

  before(:each) do
    @service = create(:service_with_ctrc_organization)
    create(:questionnaire, active: 0, items: [ Item.new( content: 'This is a test question', item_type: 'text', item_options_attributes: { "0" => { content: "" } } , description: "", required: 1 ) ], service: @service)
    create(:questionnaire, active: 0, items: [ Item.new( content: 'This is a test question', item_type: 'text', item_options_attributes: { "0" => { content: "" } } , description: "", required: 1 ) ], service: @service)
  end

  describe "Both are inactive" do

    before(:each) do
      visit service_additional_details_questionnaires_path(@service)
      expect(page).to_not have_css '.disabled'
    end

    it 'disables other inactive questionnaire buttons when one is activated' do
      first(".inactive-questionnaire").click
      wait_for_javascript_to_finish
      expect(page).to have_css '.disabled', count: @service.questionnaires.count - 1
    end

    it 're-enables other inactive questionnaire buttons when one is deactivated' do
      first(".inactive-questionnaire").click
      wait_for_javascript_to_finish
      click_button 'OK'
      first(".active-questionnaire").click
      wait_for_javascript_to_finish
      expect(page).to_not have_css '.disabled'
    end
  end

  describe "One is active" do

    before(:each) do
      @service.questionnaires.first.update_attribute(:active, 1)
      visit service_additional_details_questionnaires_path(@service)
      expect(page).to have_css '.disabled', count: @service.questionnaires.count - 1
    end

    it 're-enables other inactive questionnaire buttons when one is deactivated' do
      first(".active-questionnaire").click
      wait_for_javascript_to_finish
      expect(page).to_not have_css '.disabled'
    end
  end
end
