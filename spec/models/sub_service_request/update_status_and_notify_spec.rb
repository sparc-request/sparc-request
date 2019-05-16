# Copyright © 2011-2018 MUSC Foundation for Research Development~
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
  let!(:org)      { create(:organization_with_process_ssrs) }
  let!(:protocol) { create(:study_federally_funded, primary_pi: build_stubbed(:identity)) }
  let!(:sr)       { create(:service_request_without_validations, protocol: protocol) }

  describe "#update_status_and_notify" do
    context 'new status is different than current status' do
      context 'and the SSR can be edited' do
        context 'and current status is updatable' do
          context 'and new_status == submitted' do
            it 'should update status and nursing_nutrition, lab, imaging, and committee approvals' do
              ssr = create(:sub_service_request_without_validations, service_request: sr, organization: org)
              ssr.update_status_and_notify('submitted')
              ssr.reload

              expect(ssr.status).to eq('submitted')
              expect(ssr.nursing_nutrition_approved).to eq(false)
              expect(ssr.lab_approved).to eq(false)
              expect(ssr.imaging_approved).to eq(false)
              expect(ssr.committee_approved).to eq(false)
            end

            context 'and ssr was not previously submitted' do
              context 'and current status == draft' do
                let!(:ssr) { create(:sub_service_request_without_validations, service_request: sr, organization: org, status: 'draft') }

                context 'and past_status is nil indicating a newly created SubServiceRequest' do
                  it 'should update the SubServiceRequest and notify' do
                    expect(ssr.update_status_and_notify('submitted')).to eq(ssr.id)
                    expect(ssr.reload.status).to eq('submitted')
                  end
                end

                context 'and past_status is updatable' do
                  let!(:past_status) { create(:past_status, sub_service_request: ssr, status: 'draft') }

                  it 'should update the SubServiceRequest and notify' do
                    expect(ssr.update_status_and_notify('submitted')).to eq(ssr.id)
                    expect(ssr.reload.status).to eq('submitted')
                  end
                end

                context 'and past_status is un-updatable' do
                  let!(:past_status) { create(:past_status, sub_service_request: ssr, status: 'complete') }

                  it 'should update the SubServiceRequest but not notify' do
                    expect(ssr.update_status_and_notify('submitted')).to eq(nil)
                    expect(ssr.reload.status).to eq('submitted')
                  end
                end
              end

              context 'and current status != draft' do
                let!(:ssr) { create(:sub_service_request_without_validations, service_request: sr, organization: org, status: 'awaiting_pi_approval') }

                it 'should update the SubServiceRequest and notify' do
                  expect(ssr.update_status_and_notify('submitted')).to eq(ssr.id)
                  expect(ssr.reload.status).to eq('submitted')
                end
              end
            end

            context 'and ssr was previously submitted' do
              let!(:ssr) { create(:sub_service_request_without_validations, service_request: sr, organization: org, status: 'draft', submitted_at: DateTime.now) }

              it 'should not notify' do
                expect(ssr.update_status_and_notify('submitted')).to eq(nil)
              end
            end
          end

          context 'and new_status != submitted' do
            let!(:ssr) { create(:sub_service_request_without_validations, service_request: sr, organization: org, nursing_nutrition_approved: nil, lab_approved: nil, imaging_approved: nil, committee_approved: nil) }

            it 'should only update status and notify' do
              expect(ssr.update_status_and_notify('get_a_cost_estimate')).to eq(ssr.id)
              ssr.reload
              expect(ssr.status).to eq('get_a_cost_estimate')
              expect(ssr.nursing_nutrition_approved).to eq(nil)
              expect(ssr.lab_approved).to eq(nil)
              expect(ssr.imaging_approved).to eq(nil)
              expect(ssr.committee_approved).to eq(nil)
            end
          end
        end

        context 'and current status is un-updatable' do
          let!(:ssr) { create(:sub_service_request_without_validations, service_request: sr, organization: org, status: 'pending') }

          it 'should not update the SubServiceRequest nor notify' do
            expect(ssr.update_status_and_notify('draft')).to eq(nil)
            expect(ssr.reload.status).to eq('pending')
          end
        end
      end

      context 'and the SSR can\'t be edited' do
        let!(:ssr) {
          ssr = create(:sub_service_request_without_validations, service_request: sr, organization: org, status: 'draft')
          allow(ssr).to receive(:can_be_edited?).and_return(false)
          ssr
        }

        it 'should not update the SubServiceRequest nor notify' do
          expect(ssr.update_status_and_notify('submitted')).to eq(nil)
          expect(ssr.reload.status).to eq('draft')
        end
      end
    end

    context 'new status is the same as current status' do
      let!(:ssr) { create(:sub_service_request_without_validations, service_request: sr, organization: org, status: 'draft') }

      it 'should not update the SSR nor notify' do
        expect(ssr.update_status_and_notify('draft')).to eq(nil)
        expect(ssr.reload.status).to eq('draft')
      end
    end
  end
end
