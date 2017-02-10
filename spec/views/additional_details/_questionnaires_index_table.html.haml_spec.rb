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

RSpec.describe 'additional_details/_questionnaires_index_table', type: :view do

  before(:each) do

    @service = create(:service)
    @questionnaires = create_list(:questionnaire_with_responses, 2, :without_validations, service_id: @service.id)
    @questionnaires.first.active = 0

    render "/additional_details/questionnaires_index_table"

  end

  it 'displays the correct questionnaire information' do

    @questionnaires.each do |questionnaire|
      expect(response).to have_css('tr', text: questionnaire.name)
      expect(response).to have_css('span.badge', text: questionnaire.submissions.count)
      expect(response).to have_css('tr', text: questionnaire.service.name)
      expect(response).to have_css('tr', text: questionnaire.active ? 'true' : 'false')
      expect(response).to have_css('a', text: "#{ questionnaire.active ? 'Disable' : 'Activate' } Questionnaire")
    end

  end

  it 'displays the correct buttons' do

    expect(response).to have_css('span.glyphicon-pencil', count: @questionnaires.count)
    expect(response).to have_css('span.glyphicon-remove', count: @questionnaires.count)
    expect(response).to have_css('a', text: 'Responses', count: @questionnaires.count)

  end
end
