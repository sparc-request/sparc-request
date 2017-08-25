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

RSpec.describe 'additional_details/questionnaires/_form', type: :view do

  describe 'empty questionnaire' do

    before(:each) do
      service = create(:service)
    	questionnaire = create(:questionnaire, :without_validations, service: service)
      render "/additional_details/questionnaires/form", service: service, questionnaire: questionnaire
    end

    it 'should have the correct title' do
    	expect(response).to have_content('Form Functionality Form Builder')
    end

    it 'should have the correct buttons' do
    	expect(response).to have_css('a', text: "Add another Question")
    	expect(response).to have_css('a', text: "View Preview")
    	expect(response).to have_css('a', text: "Return to Questionnaire")
    end

    it 'should have the correct text for setting the form name' do
      expect(response).to have_content('Form Name')
      expect(response).to have_selector('input#questionnaire_name')
    end

    it 'should not have elements exclusive to questionnaires with items' do
      expect(response).to_not have_css('a', text: 'Remove Question')
      expect(response).to_not have_css('select#questionnaire_items_attributes_0_item_type')
      expect(response).to_not have_css('questionnaire_items_attributes_0_required')
    end
  end

  describe 'filled questionnaire' do

    before(:each) do
      service = create(:service)
      questionnaire = create(:questionnaire, items: [ Item.new( content: 'This is a test question', item_type: 'text', item_options_attributes: { "0" => { content: "" } } , description: "", required: 1 ) ], service: service)
      render "/additional_details/questionnaires/form", service: service, questionnaire: questionnaire
    end

    it 'should have the additional remove question button' do
      expect(response).to have_css('a', text: "Remove Question")
    end

    it 'should have the correct item type selector' do
      expect(response).to have_css('select#questionnaire_items_attributes_0_item_type', count: 1)
    end

    it 'should have the required checkbox' do
      expect(response).to have_css('input#questionnaire_items_attributes_0_required', count: 1)
    end
  end
end
