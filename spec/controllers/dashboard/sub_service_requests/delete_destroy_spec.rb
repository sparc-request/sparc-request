# Copyright © 2011-2016 MUSC Foundation for Research Development
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

RSpec.describe Dashboard::SubServiceRequestsController do
  describe 'DELETE #destroy' do
    before :each do
      @logged_in_user = create(:identity)
      log_in_dashboard_identity(obj: @logged_in_user)

      @protocol             = create(:protocol_federally_funded, primary_pi: @logged_in_user)
      @service_request      = create(:service_request_without_validations, protocol: @protocol)
      @organization         = create(:organization)
      @sub_service_request  = create(:sub_service_request_without_validations, service_request: @service_request, organization: @organization)
    end

    #####AUTHORIZATION#####
    context 'authorize admin' do
      context 'user is authorized admin' do
        before :each do
          create(:super_user, identity: @logged_in_user, organization: @organization)

          delete :destroy, id: @sub_service_request.id, format: :js
        end

        it { is_expected.to render_template "dashboard/sub_service_requests/destroy" }
        it { is_expected.to respond_with :ok }
      end

      context 'user is not authorized admin on SSR' do
        before :each do
          delete :destroy, id: @sub_service_request.id, format: :js
        end

        it { is_expected.to render_template "service_requests/_authorization_error" }
        it { is_expected.to respond_with :ok }
      end
    end

    #####INSTANCE VARIABLES#####
    context 'instance variables' do
      before :each do
        create(:super_user, identity: @logged_in_user, organization: @organization)

        delete :destroy, id: @sub_service_request.id, format: :js
      end

      it 'should assign instance variables' do
        expect(assigns(:sub_service_request)).to eq(@sub_service_request)
        expect(assigns(:admin_orgs)).to eq([@organization])
        expect(assigns(:protocol)).to eq(@protocol)
      end

      it { is_expected.to render_template "dashboard/sub_service_requests/destroy" }
      it { is_expected.to respond_with :ok }
    end

    #####TOAST MESSAGES####
    context 'toast messages' do
      before :each do
        @toast_message = create(:toast_message, sending_class: 'SubServiceRequest', sending_class_id: @sub_service_request.id)
        create(:super_user, identity: @logged_in_user, organization: @organization)
      end
      
      it 'should destroy toast messages for the SSR' do
        expect{ delete :destroy, id: @sub_service_request.id, format: :js }.to change(ToastMessage, :count).by(-1)
      end

      it 'should render_template' do
        delete(:destroy, id: @sub_service_request.id, format: :js)
        is_expected.to render_template "dashboard/sub_service_requests/destroy"
      end

      it 'should respond with ok' do
        delete(:destroy, id: @sub_service_request.id, format: :js)
        is_expected.to respond_with :ok
      end

    end

    #####NOTIFIER#####
    context 'notifier' do
      before :each do
        allow(Notifier).to receive(:sub_service_request_deleted).
          with(@logged_in_user, @sub_service_request, @logged_in_user) do
            mailer = double('mail')
            expect(mailer).to receive(:deliver)
            mailer
          end
      end

      context 'user is authorized user' do
        before :each do
          create(:super_user, identity: @logged_in_user, organization: @organization)

          delete :destroy, id: @sub_service_request.id, format: :js
        end

        it 'should notify them' do
          expect(Notifier).to have_received(:sub_service_request_deleted)
        end

        it { is_expected.to render_template "dashboard/sub_service_requests/destroy" }
        it { is_expected.to respond_with :ok }
      end

      context 'user is service provider' do
        before :each do
          create(:service_provider, organization: @organization, identity: @logged_in_user, hold_emails: false)

          delete :destroy, id: @sub_service_request.id, format: :js
        end

        it 'should notify them' do
          expect(Notifier).to have_received(:sub_service_request_deleted).twice
        end

        it { is_expected.to render_template "dashboard/sub_service_requests/destroy" }
        it { is_expected.to respond_with :ok }
      end
    end
  end
end
