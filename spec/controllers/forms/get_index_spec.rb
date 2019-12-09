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

RSpec.describe FormsController, type: :controller do
  let!(:logged_in_user) { create(:identity) }

  context '#index' do
    context "params[:complete] == 'false'" do
      it 'should assign @forms to the service request\'s associated forms' do
        org       = create(:provider)
        protocol  = create(:study_without_validations, primary_pi: logged_in_user)
        sr        = create(:service_request_without_validations, protocol: protocol)
        ssr       = create(:sub_service_request, service_request: sr, organization: org)
        form      = create(:form, surveyable: org)

        get :index, params: {
          service_request_id: sr.id,
          complete: 'false'
        }, xhr: true

        expect(assigns(:forms)).to eq(sr.associated_forms)
      end
    end

    context "params[:complete] == 'true'" do
      it 'should assign @forms to the service request\'s completed forms' do
        org       = create(:provider)
        protocol  = create(:study_without_validations, primary_pi: logged_in_user)
        sr        = create(:service_request_without_validations, protocol: protocol)
        ssr       = create(:sub_service_request, service_request: sr, organization: org)
        form      = create(:form, surveyable: org)
                    create(:response, survey: form, respondable: ssr)

        get :index, params: {
          service_request_id: sr.id,
          complete: 'true'
        }, xhr: true

        expect(assigns(:forms)).to eq(sr.completed_forms)
      end
    end
  end
end
