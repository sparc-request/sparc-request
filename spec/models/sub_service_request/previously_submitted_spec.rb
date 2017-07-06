# coding: utf-8
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

RSpec.describe SubServiceRequest, type: :model do

  let_there_be_lane

  context 'previously_submitted?' do
    before :each do
      @organization    = create(:organization, process_ssrs: true)
      @protocol        = create(:protocol_without_validations, primary_pi: jug2)
      @service_request = create(:service_request_without_validations, protocol: @protocol)
    end

    context "submitted ssr" do
      it 'should not return true' do
        ssr = create(:sub_service_request_without_validations,
                      organization: @organization,
                      service_request: @service_request,
                      submitted_at: Time.now)

        expect(ssr.previously_submitted?).to eq(true)
      end
    end
    context "not submitted ssr" do
      it 'should not return true' do
        ssr = create(:sub_service_request_without_validations,
                      organization: @organization,
                      service_request: @service_request,
                      submitted_at: nil)

        expect(ssr.previously_submitted?).to eq(false)
      end
    end
  end
end
