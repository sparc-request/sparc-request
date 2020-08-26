# Copyright © 2011-2020 MUSC Foundation for Research Development~
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

RSpec.describe ServiceRequest, type: :model do

  let!(:organization) { create(:organization) }
  let!(:service)      { create(:service, organization: organization) }
  let!(:org_form)     { create(:form, surveyable: organization, active: true) }
  let!(:service_form) { create(:form, surveyable: service, active: true) }
  let!(:protocol)     { create(:study_without_validations) }
  let!(:request)      { create(:service_request_without_validations, protocol: protocol) }
  let!(:ssr1)         { create(:sub_service_request, protocol: protocol, service_request: request, organization: organization) }
  let!(:ssr2)         { create(:sub_service_request, protocol: protocol, service_request: request, organization: organization) }
  let!(:line_item1)   { create(:line_item_without_validations, service_request: request, sub_service_request: ssr1, service: service) }
  let!(:line_item2)   { create(:line_item_without_validations, service_request: request, sub_service_request: ssr2, service: service) }

  describe '#associated_forms' do
    it 'should return all Organization and Service forms for all SubServiceRequests' do
      expect(request.reload.associated_forms.to_a).to eq(
        [
          [org_form, ssr1],
          [service_form, ssr1],
          [org_form, ssr2],
          [service_form, ssr2]
        ])
    end
  end
end
