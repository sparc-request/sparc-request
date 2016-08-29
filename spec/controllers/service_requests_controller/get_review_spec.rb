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
  build_service_request
  build_project
  build_arms

  before(:each) { arm1.update_attribute(:visit_count, 200) }

  describe 'GET review' do
    shared_examples_for 'always' do
      it 'should set @tab to full calendar' do
        expect(assigns(:tab)).to eq 'calendar'
      end

      it "should set @protocol to the ServiceRequest's Protocol" do
        expect(assigns(:service_request).protocol).to eq service_request.protocol
      end

      it "should set @service_list to the service request's service list" do
        expect(assigns(:service_request).service_list).to eq service_request.service_list
      end

      it 'should reset page for each Arm to 1' do
        expect(assigns(:pages)).to eq(arm1.id => 1, arm2.id => 1)
      end

      it 'should set @review to true' do
        expect(assigns(:review)).to be true
      end

      it 'should set @portal to false' do
        expect(assigns(:portal)).to be false
      end

      it 'should set @thead_class to \'red-provider\'' do
        expect(assigns(:thead_class)).to eq 'red-provider'
      end
    end
    
    context 'with params[:arm_id] and params[:page]' do
      before do
        session[:service_calendar_pages] = { arm1.id.to_s => '1' }
        xhr :get, :review, id: service_request.id, arm_id: arm1.id, page: 2
      end

      it "should change that Arm's service calendar's page to params[:arm_id]" do
        expect(session[:service_calendar_pages][arm1.id.to_s]).to eq '2'
      end

      include_examples 'always'
    end

    context 'with params[:pages]' do
      before do
        xhr :get, :review, { id: service_request.id, pages: { arm1.id.to_s => 42 } }.with_indifferent_access
      end

      it 'should set service_calendar_pages to params[:pages]' do
        expect(session[:service_calendar_pages]).to eq(arm1.id.to_s => '42')
      end

      include_examples 'always'
    end

    context 'without params[:pages]' do
      before do
        arm1.update_attribute(:visit_count, 200)
        xhr :get, :review, { id: service_request.id }.with_indifferent_access
      end

      include_examples 'always'
    end
  end
end
