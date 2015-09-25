# coding: utf-8
# Copyright © 2011 MUSC Foundation for Research Development
# All rights reserved.
#
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

RSpec.describe ServiceRequestsController do
  before :each do
    # authenticate user
    @identity = Identity.new
    @identity.approved = true
    @identity.save(validate: false)
    session[:identity_id] = @identity.id
    # Devise test helper method: sign_in
    sign_in @identity
    
    # mock a service request      
    @service_request = ServiceRequest.new
    # associate user to the service request to give them authorization to view its additional details
    @service_request.service_requester = @identity
    # need to set a status so the user will be authenticated
    @service_request.status = "first_draft"
    expect{
    @service_request.save(:validate => false)
    }.to change{ServiceRequest.count}.by(1)
    
    SubServiceRequest.skip_callback(:save, :after, :update_org_tree)
    @sub_service_request = SubServiceRequest.new
    @sub_service_request.service_request_id = @service_request.id
    @sub_service_request.save(:validate => false)
    SubServiceRequest.set_callback(:save, :after, :update_org_tree)
    
    # the controller looks for the service request ID in the session
    session[:service_request_id] = @service_request.id
    session[:sub_service_request_id] = @sub_service_request.id
        
    @service = Service.new
    @service.save(:validate => false)

    @line_item = LineItem.new
    @line_item.service_id = @service.id
    @line_item.sub_service_request_id = @sub_service_request.id
    @line_item.save(:validate => false)
  end

  describe 'line_item_additional_details' do
    it "should return empty json if no additional details exist" do
      get(:line_item_additional_details, { :id => @service_request.id }, :format => :json)
      expect(response.status).to eq(200)
      expect(response.body).to eq([].to_json)
    end

    describe 'with an additional detail present' do
      before :each do
        @ad = AdditionalDetail.new
        @ad.name = :test
        @ad.service_id = @service.id
        expect{
          @ad.save(:validate => false)
        }.to change(AdditionalDetail, :count).by(1)
      end

      it "should return json with additional details when additional details present" do
        get(:line_item_additional_details, { :id=>@service_request.id }, :format => :json)
        expect(response.status).to eq(200)
        expect(response.body).to eq([@ad].to_json)
      end
    end
  end
end
