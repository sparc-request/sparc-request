# coding: utf-8
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

require 'rails_helper'
require 'timecop'

RSpec.describe ServiceRequestsController do
  stub_controller

  describe 'line_item_additional_details' do
    before :each do  
      @service = Service.new
      expect{
        @service.save(:validate => false)
      }.to change(Service, :count).by(1)
     
      @line_item = LineItem.new
      @line_item.service_request_id = service_request.id
      @line_item.service_id = @service.id
      expect{
        @line_item.save(:validate => false)
      }.to change(LineItem, :count).by(1)
    end

    it "should return empty json if no additional details exist" do
      get(:line_item_additional_details, { :id=>service_request.id }, :format => :json)
        expect(response.status).to eq(200)
        expect(response.body).to eq([].to_json)  
    end
    
    before :each do
      @ad = AdditionalDetail.new
      @ad.name = :test
      @ad.service_id = @service.id
      expect{
        @ad.save(:validate => false)
      }.to change(AdditionalDetail, :count).by(1)
    end
    
    it "should return json with additional details when additional details present" do
      get(:line_item_additional_details, { :id=>service_request.id }, :format => :json)
      expect(response.status).to eq(200)
      expect(response.body).to eq([@ad].to_json)
    end
  end
end
