# Copyright © 2011-2019 MUSC Foundation for Research Development~
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
  let!(:org)      { create(:organization_with_process_ssrs) }
  let!(:protocol) { create(:study_federally_funded, primary_pi: build_stubbed(:identity)) }
  let!(:identity) { build_stubbed(:identity) }

  describe "#update_status" do
    it 'should try to update SubServiceRequests and notify' do
      sr  = create(:service_request_without_validations, protocol: protocol)
      ssr = create(:sub_service_request_without_validations, service_request: sr, organization: org)
      sr.reload
      expect_any_instance_of(SubServiceRequest).to receive(:update_status_and_notify).with('get_a_cost_estimate', identity).and_return(ssr.id)
      expect(sr.update_status('get_a_cost_estimate', identity)).to eq([ssr.id])
    end

    context 'ServiceRequest has been submitted prior' do
      let!(:sr) { create(:service_request_without_validations, :submitted, protocol: protocol) }

      it 'should not update the ServiceRequest' do
        sr.update_status('draft', identity)
        sr.reload
        expect(sr.status).to eq('submitted')
      end
    end

    context 'ServiceRequest has not been submitted prior' do
      let!(:sr) { create(:service_request_without_validations, protocol: protocol) }

      context 'and new_status == submitted' do
        before :each do
          sr.update_status('submitted', identity)
          sr.reload
        end

        it 'should update submitted_at' do
          expect(sr.status).to eq('submitted')
          expect(sr.submitted_at).not_to be_nil
        end
      end

      it 'should update the status but not submitted_at' do
        sr.update_status('get_a_cost_estimate', identity)
        sr.reload
        expect(sr.status).to eq('get_a_cost_estimate')
        expect(sr.submitted_at).to be_nil
      end
    end
  end
end
