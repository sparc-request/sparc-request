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

RSpec.describe AdditionalDetails::SubmissionsController, type: :controller do
  stub_controller
  let!(:before_filters) { find_before_filters }
  let!(:logged_in_user) { create(:identity) }

  before :each do
    org           = create(:organization)
    @service      = create(:service, organization: org)
    @service2     = create(:service, organization: org)
    @que          = create(:questionnaire, :without_validations, service: @service, active: true)
    @protocol     = create(:protocol_federally_funded, primary_pi: logged_in_user)
    @sr           = create(:service_request_without_validations, protocol: @protocol)
    ssr           = create(:sub_service_request, service_request: @sr, organization: org)
    @li           = create(:line_item, service_request: @sr, sub_service_request: ssr, service: @service)
    @li2          = create(:line_item, service_request: @sr, sub_service_request: ssr, service: @service2)
    @submission   = create(:submission, protocol: @protocol, identity: logged_in_user, service: @service, line_item: @li, questionnaire: @que)
    @submission2  = create(:submission, protocol: @protocol, identity: logged_in_user, service: @service, line_item: @li2, questionnaire: @que)

    session[:identity_id] = logged_in_user.id
  end

  describe '#destroy' do
    it 'should assign @service' do
      delete :destroy, params: {
        id: @submission.id,
        service_id: @service.id
      }, format: :js

      expect(assigns(:service)).to eq(@service)
    end

    it 'should assign @submission' do
      delete :destroy, params: {
        id: @submission.id,
        service_id: @service.id
      }, format: :js

      expect(assigns(:submission)).to eq(@submission)
    end

    context 'params[:protocol_id] present' do
      before :each do
        delete :destroy, params: {
          id: @submission.id,
          service_id: @service.id,
          protocol_id: @protocol.id
        }, format: :js
      end

      it 'should assign @protocol' do
        expect(assigns(:protocol)).to eq(@protocol)
      end

      it 'should assign @submissions' do
        expect(assigns(:submissions).to_a).to eq([@submission2])
      end

      it 'should assign @permission_to_edit' do
        expect(assigns(:permission_to_edit)).to eq(true)
      end
    end

    context 'params[:line_item_id] present' do
      before :each do
        delete :destroy, params: {
          id: @submission.id,
          service_id: @service.id,
          line_item_id: @li.id
        }, format: :js
      end

      it 'should assign @line_item' do
        expect(assigns(:line_item)).to eq(@li)
      end

      it 'should assign @service_request' do
        expect(assigns(:service_request)).to eq(@sr)
      end
    end

    it 'should destroy submission' do
      delete :destroy, params: {
        id: @submission.id,
        service_id: @service.id
      }, format: :js

      expect(Submission.count).to eq(1)
    end

    it 'should render template' do
      delete :destroy, params: {
        id: @submission.id,
        service_id: @service.id
      }, format: :js

      expect(controller).to render_template(:destroy)
    end

    it 'should respond ok' do
      delete :destroy, params: {
        id: @submission.id,
        service_id: @service.id
      }, format: :js

      expect(controller).to respond_with(:ok)
    end
  end
end
