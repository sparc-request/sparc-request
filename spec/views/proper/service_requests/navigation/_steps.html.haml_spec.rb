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

RSpec.describe '/service_request/navigation/_steps', type: :view do

  let_there_be_lane

  before(:each) do
    @protocol        = create(:unarchived_study_without_validations, primary_pi: jug2)
    @service_request = create(:service_request_without_validations, protocol: @protocol)
  end

  context 'User is currently on step 1' do
    it 'should have links on the arrows for steps 1-4' do
      render '/service_requests/navigation/steps', service_request: @service_request, sub_service_request_id: nil, step: "Step 1", step_number: '1', css_class: 'blue-provider'

      expect(response).to have_selector('a.step-btn', count: 4)
    end

    it 'should just have a div for the arrow for step 5' do
      render '/service_requests/navigation/steps', service_request: @service_request, sub_service_request_id: nil, step: "Step 1", step_number: '1', css_class: 'blue-provider'

      expect(response).to have_selector('div.step-btn', count: 1)
    end
  end

  context 'User is currently on step 2' do
    it 'should have links on the arrows for steps 1-4' do
      render '/service_requests/navigation/steps', service_request: @service_request, sub_service_request_id: nil, step: "Step 2", step_number: '2', css_class: 'blue-provider'

      expect(response).to have_selector('a.step-btn', count: 4)
    end

    it 'should just have a div for the arrow for step 5' do
      render '/service_requests/navigation/steps', service_request: @service_request, sub_service_request_id: nil, step: "Step 2", step_number: '2', css_class: 'blue-provider'

      expect(response).to have_selector('div.step-btn', count: 1)
    end
  end

  context 'User is currently on step 3' do
    it 'should have links on the arrows for steps 1-4' do
      render '/service_requests/navigation/steps', service_request: @service_request, sub_service_request_id: nil, step: "Step 3", step_number: '3', css_class: 'blue-provider'

      expect(response).to have_selector('a.step-btn', count: 4)
    end

    it 'should just have a div for the arrow for step 5' do
      render '/service_requests/navigation/steps', service_request: @service_request, sub_service_request_id: nil, step: "Step 3", step_number: '3', css_class: 'blue-provider'

      expect(response).to have_selector('div.step-btn', count: 1)
    end
  end

  context 'User is currently on step 4' do
    it 'should have links on the arrows for steps 1-4' do
      render '/service_requests/navigation/steps', service_request: @service_request, sub_service_request_id: nil, step: "Step 4", step_number: '4', css_class: 'blue-provider'

      expect(response).to have_selector('a.step-btn', count: 4)
    end

    it 'should just have a div for the arrow for step 5' do
      render '/service_requests/navigation/steps', service_request: @service_request, sub_service_request_id: nil, step: "Step 4", step_number: '4', css_class: 'blue-provider'

      expect(response).to have_selector('div.step-btn', count: 1)
    end
  end

  context 'User is currently on step 5' do
    it 'should just have a div on the arrows for steps 1-4' do
      render '/service_requests/navigation/steps', service_request: @service_request, sub_service_request_id: nil, step: "Step 5", step_number: '5', css_class: 'blue-provider'

      expect(response).to have_selector('div.step-btn', count: 4)
    end

    it 'should have a link on the arrow for step 5' do
      render '/service_requests/navigation/steps', service_request: @service_request, sub_service_request_id: nil, step: "Step 5", step_number: '5', css_class: 'blue-provider'

      expect(response).to have_selector('a.step-btn', count: 1)
    end
  end
end
