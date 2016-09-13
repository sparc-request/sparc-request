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
  let_there_be_j
  build_service_request_with_project

  describe 'GET service_subsidy' do

    before(:each) { session[:service_request_id] = service_request.id }

    context 'no SubServiceRequests' do

      before(:each) do
        service_request.sub_service_requests.each { |ssr| ssr.destroy }
        service_request.reload
        get :service_subsidy, id: service_request.id
      end

      it 'should set has_subsidies to false if there are no sub service requests' do
        expect(assigns(:has_subsidy)).to eq false
      end

      it 'should set eligible for subsidy to false if there are no sub service requests' do
        expect(assigns(:eligible_for_subsidy)).to eq false
      end

      it 'should redirect to document_management' do
        expect(response).to redirect_to "/service_requests/#{service_request.id}/document_management"
      end
    end

    context 'SubServiceRequest has a Subsidy' do

      before(:each) { get :service_subsidy, id: service_request.id }

      it 'has subsidy should return true' do
        expect(assigns(:has_subsidy)).to eq true
      end

      it 'should responsd with status 200' do
        expect(response.status).to eq 200
      end
    end

    context 'SubServiceRequest does not have a subsidy but is eligible for one' do

      before(:each) do
        sub_service_request.subsidies.destroy_all
        sub_service_request.reload
        sub_service_request.organization.subsidy_map.update_attributes(
          max_dollar_cap: 100,
          max_percentage: 100)

        get :service_subsidy, id: service_request.id
      end

      it 'has subsidy should return false' do
        expect(assigns(:has_subsidy)).to eq false
      end

      it 'eligible for subsidy should return true' do
        expect(assigns(:eligible_for_subsidy)).to eq true
      end
    end

    context 'with sub service request' do
      context 'SubServiceRequest does not have a subsidy and is not eligible for one' do

        before(:each) do
          subsidy.destroy
          subsidy_map.destroy
          # make sure before we start the test that the ssr is not eligible for subsidy
          expect(sub_service_request.eligible_for_subsidy?).to eq false

          # call service_subsidy
          get :service_subsidy, id: service_request.id

          sub_service_request.reload
        end

        it 'should redirect to document_management' do
          expect(response).to redirect_to "/service_requests/#{service_request.id}/document_management"
        end
      end
    end
  end
end
