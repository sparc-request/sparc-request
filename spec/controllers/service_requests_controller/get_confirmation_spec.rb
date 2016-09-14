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
  build_service_request_with_project

  before do
    session[:identity_id] = jug2.id
  end

  describe 'GET confirmation' do

    context 'with project' do

      it "should set the service request's status to submitted" do
        xhr :get, :confirmation, id: service_request.id
        expect(assigns(:service_request).status).to eq 'submitted'
      end

      it "should set overridden to true for all associated Subsidies" do
        service_request.subsidies.each do |s|
          s.update_attributes(overridden: true)
        end

        xhr :get, :confirmation, id: service_request.id
        expect(service_request.reload.subsidies).to all(satisfy { |s| s.overridden })
      end

      it "should set the approval attributes to false for all associated SubServiceRequests" do
        service_request.sub_service_requests.each do |ssr|
          ssr.update_attributes(:nursing_nutrition_approved => true, :lab_approved => true, :imaging_approved => true, :committee_approved => true)
        end

        xhr :get, :confirmation, id: service_request.id
        expect(service_request.reload.sub_service_requests).to all(satisfy do |ssr|
                                                                      !(ssr.nursing_nutrition_approved ||
                                                                        ssr.lab_approved ||
                                                                        ssr.imaging_approved ||
                                                                        ssr.committee_approved)
                                                                    end)
      end

      it "should set the service request's submitted_at to Time.now" do
        time = Time.parse('2012-06-01 12:34:56')
        Timecop.freeze(time) do
          service_request.update_attribute(:submitted_at, nil)
          xhr :get, :confirmation, id: service_request.id
          service_request.reload
          expect(service_request.submitted_at).to eq Time.now
        end
      end

      it "should set the service request's previous_submitted_at" do
        previous_submitted_at = service_request.submitted_at
        xhr :get, :confirmation, id: service_request.id
        expect(service_request.reload.previous_submitted_at).to eq previous_submitted_at
      end

      it 'should should set status on all the sub service request' do
        service_request.sub_service_requests.each { |ssr| ssr.destroy }

        ssr1 = create(:sub_service_request,
                      service_request_id: service_request.id,
                      ssr_id: nil,
                      organization_id: provider.id)
        ssr2 = create(:sub_service_request,
                      service_request_id: service_request.id,
                      ssr_id: nil,
                      organization_id: core.id)

        xhr :get, :confirmation, id: service_request.id

        ssr1.reload
        ssr2.reload

        expect(ssr1.status).to eq 'submitted'
        expect(ssr2.status).to eq 'submitted'
      end

      it "should set the service request's sub service requests' submitted_at to Time.now" do
        time = Time.parse('2012-06-01 12:34:56')
        Timecop.freeze(time) do
          service_request.update_attribute(:submitted_at, nil)
          xhr :get, :confirmation, id: service_request.id
          expect(service_request.sub_service_requests.first.submitted_at).to eq(Time.now)
        end
      end

      it 'should create a past status for each sub service request' do
        service_request.sub_service_requests.each { |ssr| ssr.destroy }

        ssr1 = create(:sub_service_request,
                      service_request_id: service_request.id,
                      status: 'draft',
                      organization_id: provider.id)
        ssr2 = create(:sub_service_request,
                      service_request_id: service_request.id,
                      status: 'draft',
                      organization_id: core.id)

        xhr :get, :confirmation, id: service_request.id

        ps1 = PastStatus.find_by(sub_service_request_id: ssr1.id)
        ps2 = PastStatus.find_by(sub_service_request_id: ssr2.id)

        expect(ps1.status).to eq('draft')
        expect(ps2.status).to eq('draft')
      end

      it 'should send an email if services are set to send to epic' do
        stub_const("QUEUE_EPIC", false)
        stub_const("USE_EPIC", true)

        session[:service_request_id] = service_request.id

        service.update_attributes(send_to_epic: false)
        service2.update_attributes(send_to_epic: true)
        protocol = service_request.protocol
        protocol.project_roles.first.update_attribute(:epic_access, true)
        protocol.update_attribute(:selected_for_epic, true)
        deliverer = double()
        expect(deliverer).to receive(:deliver)
        allow(Notifier).to receive(:notify_for_epic_user_approval) do |sr|
          expect(sr).to eq(protocol)
          deliverer
        end

        xhr :get, :confirmation, id: service_request.id, format: :js
      end

      it 'should not send an email if no services are set to send to epic' do
        service.update_attributes(send_to_epic: false)
        service2.update_attributes(send_to_epic: false)

        deliverer = double()
        expect(deliverer).not_to receive(:deliver)
        allow(Notifier).to receive(:notify_for_epic_user_approval) do |sr|
          expect(sr).to eq(service_request)
          deliverer
        end

        xhr :get, :confirmation, id: service_request.id, format: :js
      end
    end
  end
end
