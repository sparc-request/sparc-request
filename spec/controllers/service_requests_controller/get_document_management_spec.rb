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
  stub_controller
  let_there_be_lane

  before :each do
    session[:identity_id] = jug2.id
  end

  describe 'GET document_management' do
    it 'Should set @back to service_calendar if no SSR has or is eligible for a subsidy' do
      organization        = create(:provider)
      service_request     = create(:service_request_without_validations)
      sub_service_request = create(:sub_service_request_without_validations,
                                    service_request_id: service_request.id,
                                    organization_id: organization.id)

      xhr :get, :document_management, id: service_request.id

      expect(assigns(:back)).to eq('service_calendar')
    end

    it 'Should not set @back to service_calendar if no SSR has or is eligible for a subsidy' do
      organization        = create(:provider)
      service_request     = create(:service_request_without_validations)
      sub_service_request = create(:sub_service_request_with_subsidy,
                                    service_request_id: service_request.id,
                                    organization_id: organization.id)

      xhr :get, :document_management, id: service_request.id

      expect(assigns(:back)).to eq('service_subsidy')
    end
  end

end