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

RSpec.describe 'dashboard/service_requests/service_requests', type: :view do
  let_there_be_lane

  def render_service_requests(protocol, permission_to_edit=false)
    render 'dashboard/service_requests/service_requests',
      protocol: protocol,
      user: jug2,
      permission_to_edit: permission_to_edit,
      view_only: false
  end

  context 'Protocol has no SubServiceRequests' do
    context 'and user has appropriate rights' do
      it 'should display enabled "Add Services" button' do
        protocol  = create(:unarchived_study_without_validations, primary_pi: jug2)

        render_service_requests(protocol, true)

        expect(response).to have_selector('button:not(.disabled)', text: 'Add Services')
      end
    end

    context 'and user does not have appropriate rights' do
      it 'should display disabled "Add Services" button' do
        protocol  = create(:unarchived_study_without_validations, primary_pi: create(:identity))

        render_service_requests(protocol)

        expect(response).to have_selector('button.disabled', text: 'Add Services')
      end
    end
  end

  context 'Protocol has SubServiceRequests' do
    it 'should render Service Requests with Sub Service Requests' do
      protocol        = create(:unarchived_study_without_validations, primary_pi: jug2)
      service_request = create(:service_request_without_validations, protocol: protocol)
                        create(:sub_service_request_without_validations, service_request: service_request, organization: create(:organization), status: 'draft')

      render_service_requests(protocol)

      expect(response).to render_template(partial: 'dashboard/service_requests/protocol_service_request_show',
      locals: {
        service_request: service_request,
        user: jug2,
        permission_to_edit: false,
        view_only: false
      }
    )
    end

    it 'should not render Service Requests without Sub Service Requests' do
      protocol                  = create(:unarchived_study_without_validations, primary_pi: jug2)
      service_request           = create(:service_request_without_validations, protocol: protocol)
      service_request_with_ssr  = create(:service_request_without_validations, protocol: protocol)
                                  create(:sub_service_request_without_validations, service_request: service_request_with_ssr, organization: create(:organization))

        render_service_requests(protocol)

        expect(response).not_to render_template(partial: 'dashboard/service_requests/protocol_service_request_show',
        locals: {
          service_request: service_request,
          user: jug2,
          permission_to_edit: false,
          view_only: false
        }
      )
    end
  end

  context 'Service Request with all \'first_draft\'' do
    it 'should not render' do
      protocol        = create(:unarchived_study_without_validations, primary_pi: jug2)
      service_request = create(:service_request_without_validations, protocol: protocol)
                        create(:sub_service_request_without_validations, service_request: service_request, organization: create(:organization), status: 'first_draft')

      render_service_requests(protocol)

      expect(response).not_to render_template(partial: 'dashboard/service_requests/protocol_service_request_show',
        locals: {
          service_request: service_request,
          user: jug2,
          permission_to_edit: false,
          view_only: false
        }
      )
    end
  end
end
