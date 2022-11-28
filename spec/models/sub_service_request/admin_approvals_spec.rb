# Copyright © 2011-2022 MUSC Foundation for Research Development
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

RSpec.describe SubServiceRequest, type: :model do

  let_there_be_lane

  context 'ssr has admin approvals' do
    before :each do
      @org             = create(:organization, process_ssrs: true)
      @protocol        = create(:protocol_without_validations, primary_pi: jug2)
      @sr              = create(:service_request_without_validations, protocol: @protocol)
      @ssr             = create(:sub_service_request_without_validations, organization: @org, service_request: @sr, status: 'complete')
      @identity        = build_stubbed(:identity)
    end

    it 'should check the nursing/nutrition approval correctly' do
      create(:approval, sub_service_request: @ssr, approval_type: 'Nursing/Nutrition Approved')
      expect(@ssr.nursing_nutrition_approved?).to eq(true)
    end

    it 'should check the lab approval correctly' do
      create(:approval, sub_service_request: @ssr, approval_type: 'Lab Approved')
      expect(@ssr.lab_approved?).to eq(true)
    end

    it 'should check the imaging approval correctly' do
      create(:approval, sub_service_request: @ssr, approval_type: 'Imaging Approved')
      expect(@ssr.imaging_approved?).to eq(true)
    end

    it 'should check the committee approval correctly' do
      create(:approval, sub_service_request: @ssr, approval_type: 'Committee Approved')
      expect(@ssr.committee_approved?).to eq(true)
    end

    it 'should not reset the admin approvals when ssr is resubmitted' do
      @approval1 = create(:approval, sub_service_request: @ssr, approval_type: 'Nursing/Nutrition Approved')
      @approval2 = create(:approval, sub_service_request: @ssr, approval_type: 'Imaging Approved')
      @past_staus = create(:past_status, sub_service_request: @ssr, status: 'draft')
      @ssr.update_attributes(status: 'draft')

      @ssr.reload
      expect(@ssr.update_status_and_notify('submitted', @identity)).to eq(@ssr.id)

      expect(Approval.count).to eq(2)
      expect(@ssr.reload.nursing_nutrition_approved?).to eq(true)
      expect(@ssr.reload.imaging_approved?).to eq(true)
    end

  end

end

