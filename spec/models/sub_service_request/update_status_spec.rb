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

RSpec.describe 'SubServiceRequest' do

  let_there_be_lane
  let_there_be_j
  build_service_request_with_study

  describe '#update_status' do
    it 'should return update ssr status to "submitted"' do
      sub_service_request.update_status('submitted')
      expect(sub_service_request.status).to eq('submitted')
    end

    it 'should update submitted_at date' do
      sub_service_request.update_status('submitted')
      expect(sub_service_request.submitted_at).not_to eq(nil)
    end

    it 'should update nursing_nutrition_approved to false' do
      sub_service_request.update_attribute(:nursing_nutrition_approved, nil)
      sub_service_request.update_status('submitted')
      expect(sub_service_request.nursing_nutrition_approved).to eq(false)
    end

    it 'should update nursing_nutrition_approved to false' do
      sub_service_request.update_attribute(:lab_approved, nil)
      sub_service_request.update_status('submitted')
      expect(sub_service_request.lab_approved).to eq(false)
    end

    it 'should update nursing_nutrition_approved to false' do
      sub_service_request.update_attribute(:imaging_approved, nil)
      sub_service_request.update_status('submitted')
      expect(sub_service_request.imaging_approved).to eq(false)
    end

    it 'should update nursing_nutrition_approved to false' do
      sub_service_request.update_attribute(:committee_approved, nil)
      sub_service_request.update_status('submitted')
      expect(sub_service_request.committee_approved).to eq(false)
    end

    it 'should ' do
      sub_service_request.update_attribute(:status, 'submitted')
      sub_service_request.update_status('submitted')
      expect(sub_service_request.submitted_at).to eq(nil)
    end
  end
end