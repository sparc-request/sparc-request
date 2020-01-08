# Copyright © 2011-2019 MUSC Foundation for Research Development
# All rights reserved.

# Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:

# 1. Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.

# 2. Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following
# disclaimer in the documentation and/or other materials provided with the distribution.

# 3. Neither the name of the copyright holder nor the names of its contributors may be used to endorse or promote products
# derived from this software without specific prior written permission.

# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING,
# BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT
# SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
# DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
# INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR
# TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

require 'rails_helper'

RSpec.describe ServiceRequestsController, type: :controller do
  stub_controller
  let!(:logged_in_user) { create(:identity) }

  let!(:org)      { create(:organization) }
  let!(:service)  { create(:service, organization: org, one_time_fee: true) }
  let!(:protocol) { create(:protocol_federally_funded, primary_pi: logged_in_user, type: 'Study') }
  let!(:sr)       { create(:service_request_without_validations, protocol: protocol, submitted_at: '2015-02-10') }
  let!(:ssr)      { create(:sub_service_request_without_validations, service_request: sr, organization: org, protocol_id: protocol.id) }
  let!(:li)       { create(:line_item, service_request: sr, sub_service_request: ssr, service: service) }

  before :each do
    session[:identity_id] = logged_in_user.id
  end

  describe '#confirmation' do
    it 'should call the Notifier Logic to update the request' do
      expect(NotifierLogic).to receive_message_chain(:delay, :confirmation_logic)

      get :confirmation, params: { srid: sr.id }, xhr: true

      expect(assigns(:service_request).previous_submitted_at).to eq(sr.submitted_at)
    end

    context 'Epic config enabled and request should be pushed to epic' do
      stub_config('use_epic', true)

      before :each do
        allow_any_instance_of(ServiceRequest).to receive(:should_push_to_epic?).and_return(true)
        allow_any_instance_of(Study).to receive(:selected_for_epic?).and_return(true)
      end

      context 'Epic queue enabled' do
        stub_config('queue_epic', true)

        context 'epic queue record already present' do
          before :each do
            @eq = create(:epic_queue, protocol: protocol, user_change: true)
          end

          it 'should update the existing record' do
            expect {
              get :confirmation, params: { srid: sr.id }, xhr: true
            }.to change{ EpicQueue.count }.by(0)

            expect(@eq.reload.user_change).to eq(false)
          end
        end

        context 'no epic queue record present' do
          before :each do
            allow(controller).to receive(:should_queue_epic?).and_return(true)
          end

          it 'should create a queue record' do
            expect {
              get :confirmation, params: { srid: sr.id }, xhr: true
            }.to change{ EpicQueue.count }.by(1)
          end
        end
      end

      context 'Epic queue disabled' do
        stub_config('queue_epic', false)

        it 'should send an epic approval notification' do
          expect(Notifier).to receive_message_chain(:notify_for_epic_user_approval, :deliver)

          get :confirmation, params: { srid: sr.id }, xhr: true
        end
      end
    end
  end
end
