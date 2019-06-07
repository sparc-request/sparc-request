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

RSpec.describe ApplicationController, type: :controller do

  let_there_be_lane

  describe '#current_user' do
    it 'should call current_identity' do
      expect(controller).to receive(:current_identity)
      controller.send(:current_user)
    end
  end

  describe '#authorize_identity' do
    context '@service_request is \'first_draft\'' do
      it 'should return true' do
        sr = build(:service_request, status: 'first_draft')
        controller.instance_variable_set(:@service_request, sr)
        expect(controller).to_not receive(:authorization_error)
        controller.send(:authorize_identity)
      end
    end

    context '@service_request is not \'first_draft\'' do
      context 'Identity logged in' do
        before(:each) do
          allow(controller).to receive(:current_user).and_return(jug2)
        end

        context 'user can edit @service_request' do
          it 'should authorize identity' do
            sr = build(:service_request, status: 'draft')
            controller.instance_variable_set(:@service_request, sr)
            allow(jug2).to receive(:can_edit_service_request?).with(sr).and_return(true)
            expect(controller).to_not receive(:authorization_error)
            controller.send(:authorize_identity)
          end
        end

        context 'user can not edit @service_request' do
          it 'should authorize identity' do
            sr = build(:service_request, status: 'draft')
            controller.instance_variable_set(:@service_request, sr)
            allow(jug2).to receive(:can_edit_service_request?).with(sr).and_return(false)
            expect(controller).to receive(:authorization_error)
            controller.send(:authorize_identity)
          end
        end
      end

      context 'Identity not logged in' do
        it 'should call \'authenticate_identity!\'' do
          service_request = instance_double('ServiceRequest', status: 'draft')
          controller.instance_variable_set(:@service_request, service_request)
          allow(controller).to receive(:not_signed_in?).and_return(true)
          expect(controller).to receive(:authenticate_identity!)
          expect(controller).to_not receive(:authorization_error)
          controller.send(:authorize_identity)
        end
      end
    end
  end

  describe '#initialize_service_request' do
    context 'params[:srid] is present' do
      it 'should assign @service_request' do
        sr = findable_stub(ServiceRequest) { build_stubbed(:service_request) }
        allow(controller).to receive(:params).and_return({srid: sr.id.to_s})
        controller.send(:initialize_service_request)
        expect(assigns(:service_request)).to eq(sr)
      end
    end

    context 'action_name == \'add_service\'' do
      it 'should create a new service request' do
        allow(controller).to receive(:action_name).and_return('add_service')
        controller.send(:initialize_service_request)
        sr = ServiceRequest.first
        expect(assigns(:service_request)).to eq(sr)
        expect(sr.status).to eq('first_draft')
      end
    end

    context 'service request not yet created' do
      it '@service_request is unsaved' do
        controller.send(:initialize_service_request)
        sr = assigns(:service_request)
        expect(sr.new_record?).to eq(true)
      end
    end
  end
end
