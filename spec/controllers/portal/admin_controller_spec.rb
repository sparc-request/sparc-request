# Copyright © 2011 MUSC Foundation for Research Development
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

require 'spec_helper'

describe Portal::AdminController, :type => :controller do
  stub_portal_controller

  let_there_be_lane
  let_there_be_j
  build_service_request_with_project

  let!(:identity)             { FactoryGirl.create(:identity) }
  let!(:service_provider)     { FactoryGirl.create(:service_provider, identity_id: identity.id, organization_id: core.id, hold_emails: false) }
  let!(:message) { ToastMessage.create(from: 'CmdrTaco@slashdot.org', to: 'esr@fsf.org', message: 'happy birthday!') }

  before :each do
    @service_request = ServiceRequest.new(FactoryGirl.attributes_for(:service_request, :protocol_id => project.id))
    @service_request.save(:validate => false)
    @project_role = FactoryGirl.create(:project_role, protocol_id: project.id, identity_id: identity.id, project_rights: "approve", role: "primary_pi") 
    @sub_service_request1 = FactoryGirl.create(:sub_service_request, status: 'yo_mama', service_request_id: @service_request.id, organization_id: core.id ) 
    @sub_service_request2 = FactoryGirl.create(:sub_service_request, status: 'his_mama', service_request_id: @service_request.id, organization_id: core.id ) 
  end
  
  describe 'GET index' do
    it 'should set service_requests' do  
      session[:identity_id] = identity.id
      get(:index, format: :js)
      assigns(:service_requests).count.should eq 2
      # TODO: check contents of the hash
    end
  end

  describe 'POST delete_toast_message' do
    it 'should set message' do
      get(:delete_toast_message, {
        format: :js,
        id: message.id,
      }.with_indifferent_access)
      assigns(:message).should eq message
    end

    it 'should delete the message' do
      get(:delete_toast_message, {
        format: :js,
        id: message.id,
      }.with_indifferent_access)
      expect { message.reload }.to raise_exception(ActiveRecord::RecordNotFound)
    end
  end
end

