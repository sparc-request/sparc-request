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
  let!(:organization)     { create(:organization) }
  let!(:service_epic)     { create(:service, organization: organization, send_to_epic: true) }
  let!(:service_no_epic)  { create(:service, organization: organization, send_to_epic: false) }

  describe '#should_push_to_epic?' do
    context 'epic is enabled' do
      stub_config('use_epic', true)

      context 'protocol is selected for epic' do
        let!(:protocol) { create(:study_federally_funded, primary_pi: create(:identity), selected_for_epic: true) }

        context 'new ServiceRequest' do
          let!(:sr) { create(:service_request, protocol: protocol, submitted_at: nil) }
          let!(:ssr) { create(:sub_service_request, service_request: sr, organization: organization) }

          context 'services are selected for epic' do
            let!(:li) { create(:line_item, service_request: sr, sub_service_request: ssr, service: service_epic) }

            it 'should return true' do
              expect(sr.should_push_to_epic?).to eq(true)
            end
          end

          context 'services are not selected for epic' do
            let!(:li) { create(:line_item, service_request: sr, sub_service_request: ssr, service: service_no_epic) }

            it 'should return false' do
              expect(sr.should_push_to_epic?).to eq(false)
            end
          end
        end

        context 'ServiceRequest is previously submitted' do
          let!(:sr) { create(:service_request, :submitted, protocol: protocol) }

          context 'Draft SSR to be resubmitted' do
            let!(:ssr) { create(:sub_service_request, service_request: sr, organization: organization, status: 'draft', submitted_at: DateTime.now) }

            context 'services are selected for epic' do
              let!(:li) { create(:line_item, service_request: sr, sub_service_request: ssr, service: service_epic) }

              it 'should return true' do
                expect(sr.should_push_to_epic?).to eq(true)
              end
            end

            context 'services are not selected for epic' do
              let!(:li) { create(:line_item, service_request: sr, sub_service_request: ssr, service: service_no_epic) }

              it 'should return false' do
                expect(sr.should_push_to_epic?).to eq(false)
              end
            end
          end

          context 'No draft SSRs to be resubmitted' do
            let!(:ssr) { create(:sub_service_request, :submitted, service_request: sr, organization: organization) }
            let!(:li) { create(:line_item, service_request: sr, sub_service_request: ssr, service: service_epic) }

            it 'should return false' do
              expect(sr.should_push_to_epic?).to eq(false)
            end
          end
        end

        context 'protocol is not selected for epic' do
          let!(:protocol) { create(:study_federally_funded, primary_pi: create(:identity), selected_for_epic: false) }
          let!(:sr)       { create(:service_request, protocol: protocol) }

          it 'should return false' do
            expect(sr.should_push_to_epic?).to eq(false)
          end
        end
      end
    end

    context 'epic is disabled' do
      stub_config('use_epic', false)

      let!(:sr) { create(:service_request_without_validations) }

      it 'should return false' do
        expect(sr.should_push_to_epic?).to eq(false)
      end
    end
  end
end
