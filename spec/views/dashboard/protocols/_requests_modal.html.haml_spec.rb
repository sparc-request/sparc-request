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

# TODO rewrite with stubs
require 'rails_helper'

RSpec.describe 'dashboard/protocols/requests_modal', type: :view do
  let_there_be_lane

  def render_requests_modal(protocol)
    render 'dashboard/protocols/requests_modal',
      protocol: protocol,
      user: jug2,
      permission_to_edit: false,
      view_only: true
  end

  it 'should render Service Requests with Sub Service Requests' do
    protocol                  = create(:protocol_federally_funded, :without_validations, primary_pi: jug2, type: 'Study', archived: false)
    service_request_with_ssr  = create(:service_request_without_validations, protocol: protocol)
                                create(:sub_service_request, service_request: service_request_with_ssr, organization: create(:organization), status: 'draft')

    render_requests_modal(protocol)

    expect(response).to render_template(partial: 'dashboard/service_requests/protocol_service_request_show',
      locals: {
        service_request: service_request_with_ssr,
        user: jug2,
        permission_to_edit: false,
        view_only: true
      }
    )
  end

  it 'should not render Service Request without Sub Service Requests' do
    protocol                    = create(:protocol_federally_funded, :without_validations, primary_pi: jug2, type: 'Study', archived: false)
    service_request_without_ssr = create(:service_request_without_validations, protocol: protocol)
    
    render_requests_modal(protocol)

    expect(response).not_to render_template(partial: 'dashboard/service_requests/protocol_service_request_show',
      locals: {
        service_request: service_request_without_ssr,
        user: jug2,
        permission_to_edit: false,
        view_only: true
      }
    )
  end

  context 'Service Request with all \'first_draft\'' do
    it 'should not render' do
      protocol        = create(:unarchived_study_without_validations, primary_pi: jug2)
      service_request = create(:service_request_without_validations, protocol: protocol)
                        create(:sub_service_request_without_validations, service_request: service_request, organization: create(:organization), status: 'first_draft')

      render_requests_modal(protocol)

      expect(response).not_to render_template(partial: 'dashboard/service_requests/protocol_service_request_show',
        locals: {
          service_request: service_request,
          user: jug2,
          permission_to_edit: false,
          view_only: true
        }
      )
    end
  end
end
