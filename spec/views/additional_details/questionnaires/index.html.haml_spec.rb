# Copyright © 2011-2016 MUSC Foundation for Research Development~
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

RSpec.describe 'additional_details/questionnaires/index', type: :view do

  describe 'with no responses and active' do

    before(:each) do
      @service = create(:service, name: 'Test Service')
      @questionnaire = create(:questionnaire, :without_validations, name: 'Test Questionnaire', active: 1, service: @service)

      assign(:service, @service)
      assign(:questionnaires, [@questionnaire])
      assign(:service_id, @service.id)

      render
    end

    it 'should display the correct questionnaire summary' do
      expect(response).to have_content(@service.name)
      expect(response).to have_content(@questionnaire.name)
      expect(response).to have_content(@questionnaire.active ? 'true' : 'false')
    end

    it 'should display the correct number of responses' do
      expect(response).to have_css('a', text: 'Responses')
      expect(response).to have_css('span', text: @questionnaire.submissions.count.to_s)
    end

    it 'should have all of the correct buttons' do
      expect(response).to have_css('a', text: "#{@questionnaire.active ? 'Disable' : 'Activate'} Questionnaire")
      expect(response).to have_css('a', text: "Create new")
      
    end
  end

  describe 'with responses and inactive' do

    before(:each) do
      submission = create(:submission)
      @service = create(:service, name: 'Test Service')
      @questionnaire = create(:questionnaire, :without_validations, name: 'Test Questionnaire', active: 0, submissions: [submission], service: @service)
      assign(:service, @service)
      assign(:questionnaires, [@questionnaire])
      assign(:service_id, @service.id)

      render
    end

    it 'should pull from the correct questionnaire' do
      expect(response).to have_content(@service.name)
      expect(response).to have_content(@questionnaire.name)
      expect(response).to have_content(@questionnaire.active ? 'true' : 'false')
    end

    it 'should display the number of responses correctly' do
      expect(response).to have_css('a', text: 'Responses')
      expect(response).to have_css('span', text: @questionnaire.submissions.count.to_s)
    end
  end
end
