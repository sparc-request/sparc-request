# Copyright © 2011-2019 MUSC Foundation for Research Development~
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

RSpec.describe 'dashboard/protocols/show', type: :view do
  let_there_be_lane

  before(:each) do
    org       = create(:organization)
    service   = create(:service, organization: org)
    @protocol = create(:study_without_validations, primary_pi: jug2, type: 'Study', archived: false, short_title: 'My Awesome Short Title')
    sr        = create(:service_request_without_validations, protocol: @protocol)
    ssr       = create(:sub_service_request, organization: org, service_request: sr)
    li        = create(:line_item, sub_service_request: ssr, service_request: sr, service: service)

    assign(:user, jug2)
    assign(:protocol, @protocol)
    assign(:protocol_type, @protocol.type)
    assign(:permission_to_edit, false)
    assign(:sub_service_request, ssr)
    allow(view).to receive(:current_identity).and_return(jug2)
    render
  end

  it 'should render dashboard/protocols/summary' do
    expect(response).to render_template(partial: 'dashboard/protocols/_summary',
      locals: { protocol: @protocol })
  end

  it 'should render dashboard/associated_users/table' do
    expect(response).to render_template(partial: 'dashboard/associated_users/_table',
      locals: { protocol: @protocol })
  end

  it 'should render dashboard/service_requests/service_requests' do
    expect(response).to render_template(partial: 'dashboard/service_requests/service_requests',
      locals: { protocol: @protocol, permission_to_edit: false })
  end
end
