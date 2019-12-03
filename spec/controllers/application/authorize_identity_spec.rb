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
  let!(:logged_in_user) { create(:identity) }

  describe '#authorize_identity' do
    before :each do
      allow(controller).to receive(:authenticate_identity!)
      allow(controller).to receive(:current_user).and_return(logged_in_user)
    end

    context '@service_request is \'first_draft\'' do
      context 'viewing the catalog' do
        it 'should return permit' do
          sr = build(:service_request, status: 'first_draft')
          controller.instance_variable_set(:@service_request, sr)
          allow(controller).to receive(:action_name).and_return('catalog')
          expect(controller).to_not receive(:authorization_error)
          controller.send(:authorize_identity)
        end
      end

      context 'JS request sent from the catalog' do
        it 'should permit' do
          sr = build(:service_request, status: 'first_draft')
          controller.instance_variable_set(:@service_request, sr)
          allow(controller).to receive_message_chain(:request, :referrer).and_return('/service_request/catalog')
          allow(controller).to receive_message_chain(:request, :format, :js?).and_return(true)
          expect(controller).to_not receive(:authorization_error)
          controller.send(:authorize_identity)
        end
      end

      context 'sent from a different page' do
        it 'should not permit' do
          sr = build(:service_request, status: 'first_draft')
          controller.instance_variable_set(:@service_request, sr)
          allow(controller).to receive_message_chain(:request, :referrer).and_return('/service_request/protocol')
          allow(controller).to receive_message_chain(:request, :format, :js?).and_return(false)
          allow(controller).to receive(:identity_signed_in?).and_return(true)
          expect(controller).to receive(:authorization_error)
          controller.send(:authorize_identity)
        end
      end
    end

    context '@service_request is not \'first_draft\'' do
      context 'user logged in' do
        before :each do
          allow(controller).to receive(:authenticate_identity!)
          allow(controller).to receive(:current_user).and_return(logged_in_user)
        end

        context 'user can edit service request' do
          it 'should permit' do
            sr = build(:service_request, status: 'draft')
            controller.instance_variable_set(:@service_request, sr)
            allow(logged_in_user).to receive(:can_edit_service_request?).with(sr).and_return(true)
            expect(controller).to_not receive(:authorization_error)
            controller.send(:authorize_identity)
          end
        end

        context 'user can\'t edit service request' do
          it 'should not permit' do
            sr = build(:service_request, status: 'draft')
            controller.instance_variable_set(:@service_request, sr)
            allow(logged_in_user).to receive(:can_edit_service_request?).with(sr).and_return(true)
            expect(controller).to_not receive(:authorization_error)
            controller.send(:authorize_identity)
          end
        end
      end

      context 'user not logged in' do
        before :each do
          allow(controller).to receive(:authenticate_identity!)
          allow(controller).to receive(:identity_signed_in?).and_return(false)
        end

        it 'should require a login' do
          sr = build(:service_request, status: 'draft')
          controller.instance_variable_set(:@service_request, sr)
          expect(controller).to receive(:authenticate_identity!)
          expect(controller).to_not receive(:authorization_error)
          controller.send(:authorize_identity)
        end
      end
    end
  end
end
