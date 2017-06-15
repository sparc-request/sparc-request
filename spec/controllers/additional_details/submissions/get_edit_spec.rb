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
    org         = create(:organization)
    @service    = create(:service, organization: org)
    @que        = create(:questionnaire, :without_validations, service: @service, active: true)
    protocol    = create(:protocol_federally_funded, primary_pi: logged_in_user)
    sr          = create(:service_request_without_validations, protocol: protocol)
    ssr         = create(:sub_service_request, service_request: sr, organization: org)
    li          = create(:line_item, service_request: sr, sub_service_request: ssr, service: @service)
    @submission = create(:submission, protocol: protocol, identity: logged_in_user, service: @service, line_item: li, questionnaire: @que)

    get :edit, params: {
      id: @submission.id,
      service_id: @service.id
    }, xhr: true
  end

  describe '#edit' do
    it 'should assign @service' do
      expect(assigns(:service)).to eq(@service)
    end

    it 'should assign @submission' do
      expect(assigns(:submission)).to eq(@submission)
    end

    it 'should assign @questionnaire' do
      expect(assigns(:questionnaire)).to eq(@que)
    end

    it 'should render template' do
      expect(controller).to render_template(:edit)
    end

    it 'should respond ok' do
      expect(controller).to respond_with(:ok)
    end
  end
end
