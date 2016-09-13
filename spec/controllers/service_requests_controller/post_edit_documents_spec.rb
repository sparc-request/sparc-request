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

  describe 'POST edit_documents' do
    let!(:protocol)             { create(:protocol_without_validations, primary_pi: jug2) }
    let!(:service_request)      { create(:service_request_without_validations, protocol: protocol) }
    let!(:organization)         { create(:organization) }
    let!(:sub_service_request)  { create(:sub_service_request_without_validations, service_request: service_request, organization: organization) }
    let!(:doc)                  { create(:document, protocol: protocol) }

    before(:each) do
      doc.sub_service_requests << sub_service_request
      session[:service_request_id] = service_request.id
      allow(controller).to receive(:initialize_service_request) do
        controller.instance_eval do
          @service_request = ServiceRequest.find(session[:service_request_id])
        end
        allow(controller.instance_variable_get(:@service_request)).to receive(:service_list) { :service_list }
      end
    end

    it 'should set @document' do
      post :edit_documents, {
        id: service_request.id,
        document_id: doc.id,
        format: :js
      }.with_indifferent_access
      expect(assigns(:document)).to eq doc
    end

    it 'should set @service_list' do
      post :edit_documents, {
        id: service_request.id,
        document_id: doc.id,
        format: :js
      }.with_indifferent_access
      expect(assigns(:service_list)).to eq :service_list
    end
  end
end
