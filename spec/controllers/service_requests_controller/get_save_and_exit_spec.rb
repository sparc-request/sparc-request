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
require 'timecop'

RSpec.describe ServiceRequestsController do
  stub_controller

  let_there_be_lane
  let_there_be_j

  describe 'GET save_and_exit' do
    context 'with project' do
      build_service_request_with_project

      shared_examples_for 'always' do
        it 'should redirect the user to the user portal link' do
          get :save_and_exit, id: service_request.id
          expect(response).to redirect_to(DASHBOARD_LINK)
        end
      end

      context 'without params[:sub_service_request_id]' do
        it 'should set the status of the ServiceRequest and associated SubServiceRequests to draft' do
          service_request.update_status('not draft')
          get :save_and_exit, id: service_request.id
          service_request.reload
          expect(service_request.status).to eq 'draft'
          expect(service_request.sub_service_requests).to all(satisfy { |ssr| ssr.status == 'draft' })
        end

        it "should not set the service request's submitted_at to Time.now" do
          time = Time.parse('2012-06-01 12:34:56')
          Timecop.freeze(time) do
            service_request.update_attribute(:submitted_at, nil)
            get :save_and_exit, id: service_request.id
            service_request.reload
            expect(service_request.submitted_at).to eq nil
          end
        end

        it 'should set ssr_id on all associated SubServiceRequests' do
          session[:service_request_id] = service_request.id
          allow(controller).to receive(:initialize_service_request) do
            controller.instance_eval do
              @service_request = ServiceRequest.find_by_id(session[:service_request_id])
              @sub_service_request = SubServiceRequest.find_by_id(session[:sub_service_request_id])
            end
            expect(controller.instance_variable_get(:@service_request)).to receive(:ensure_ssr_ids)
          end
          get :save_and_exit, id: service_request.id
        end

        it 'should should set status of all associated SubServiceRequests to draft' do
          service_request.protocol.update_attribute(:next_ssr_id, 42)

          service_request.sub_service_requests.each(&:destroy)
          ssr1 = create(:sub_service_request, service_request_id: service_request.id, ssr_id: nil, organization_id: core.id)
          ssr2 = create(:sub_service_request, service_request_id: service_request.id, ssr_id: nil, organization_id: core.id)

          get :save_and_exit, id: service_request.id

          ssr1.reload
          ssr2.reload

          expect(ssr1.status).to eq 'draft'
          expect(ssr2.status).to eq 'draft'
        end

        it 'should create a past status for each SubServiceRequest' do
          service_request.sub_service_requests.each(&:destroy)

          session[:identity_id] = jug2.id

          ssr1 = create(:sub_service_request,
                        service_request_id: service_request.id,
                        status: 'first_draft',
                        organization_id: provider.id)
          ssr2 = create(:sub_service_request,
                        service_request_id: service_request.id,
                        status: 'first_draft',
                        organization_id: core.id)

          xhr :get, :save_and_exit, id: service_request.id

          ps1 = PastStatus.find_by(sub_service_request_id: ssr1.id)
          ps2 = PastStatus.find_by(sub_service_request_id: ssr2.id)

          expect(ps1.status).to eq('first_draft')
          expect(ps2.status).to eq('first_draft')
        end

        it 'should set ssr_id correctly when next_ssr_id > 9999' do
          service_request.protocol.update_attribute(:next_ssr_id, 10_042)

          service_request.sub_service_requests.each(&:destroy)
          ssr1 = create(:sub_service_request, service_request_id: service_request.id, ssr_id: nil, organization_id: core.id)

          get :save_and_exit, id: service_request.id

          ssr1.reload
          expect(ssr1.ssr_id).to eq '10042'
        end
      end

    end
  end
end
