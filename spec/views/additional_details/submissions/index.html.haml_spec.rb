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

RSpec.describe 'additional_details/submissions/index', type: :view do

  before(:each) do
    @service = create(:service)
    @user = create(:identity)
    @submissions = create_list(:submission, 5, service_id: @service.id, identity_id: @user.id)

    render
  end

  it 'should have the correct table headers' do
    expect(response).to have_content(@service.name)
    expect(response).to have_css('th', text: 'Submission')
    expect(response).to have_css('th', text: 'Completed By')
    expect(response).to have_css('th', text: 'Show')
    expect(response).to have_css('th', text: 'Edit')
    expect(response).to have_css('th', text: 'Delete')
  end

  it 'should have the correct buttons' do
    expect(response).to have_css('span.glyphicon-search', count: @submissions.count)
    expect(response).to have_css('span.glyphicon-edit', count: @submissions.count)
    expect(response).to have_css('span.glyphicon-remove', count: @submissions.count)
  end

  it 'should have the correct information for the submissions' do
    expect(response).to have_css('tr', text: @user.email, count: @submissions.count)
    @submissions.each{ |submission| expect(response).to have_css('tr', text: submission.id) }
  end

end