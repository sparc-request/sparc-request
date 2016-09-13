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
require 'timecop'

RSpec.describe ServiceRequestsController do
  stub_controller
  let_there_be_lane
  let_there_be_j
  build_service_request_with_study
  build_one_time_fee_services
  build_per_patient_per_visit_services

  describe 'GET show' do

    context 'without params[:admin_offset]' do

      before(:each) do
        xhr :get, :show, id: service_request.id
      end

      it 'should set protocol' do
        expect(assigns(:protocol)).to eq service_request.protocol
      end

      it 'should not set admin_offset' do
        expect(assigns(:admin_offset)).to_not be
      end
    end

    context 'with params[:admin_offset]' do

      before(:each) do
        xhr :get, :show, id: service_request.id, admin_offset: 10
      end

      it 'should set protocol' do
        expect(assigns(:protocol)).to eq service_request.protocol
      end

      it 'should set admin_offset' do
        expect(assigns(:admin_offset)).to eq '10'
      end
    end
  end
end
