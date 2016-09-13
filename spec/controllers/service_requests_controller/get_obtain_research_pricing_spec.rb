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

RSpec.describe ServiceRequestsController do

  describe 'GET obtain_research_pricing'
    stub_controller

    let_there_be_lane
    let_there_be_j

    before :each do
      session[:identity_id] = jug2.id
      @protocol = create(:study_without_validations,
                          primary_pi: jug2)
      @organization = create(:provider)
      @service_request = create(:service_request_without_validations,
                                   status: 'draft',
                                   protocol: @protocol)
      @sub_service_request = create(:sub_service_request,
                    service_request_id: @service_request.id,
                    status: 'draft',
                    organization_id: @organization.id)
    end

    context 'Editing a sub_service_request' do
      it 'Should create a past_status for the sub_service_request' do
        xhr :get, :obtain_research_pricing,
                   id: @service_request.id,
                   sub_service_request_id: @sub_service_request.id

        ps = PastStatus.find_by(sub_service_request_id: @sub_service_request.id)

        expect(ps.status).to eq('draft')
      end 
    end

    context 'Editing a service_request' do 
      it 'Should create a past_status for the sub_service_request' do
        xhr :get, :obtain_research_pricing,
             id: @service_request.id

        ps = PastStatus.find_by(sub_service_request_id: @sub_service_request.id)

        expect(ps.status).to eq('draft')
      end
    end

end