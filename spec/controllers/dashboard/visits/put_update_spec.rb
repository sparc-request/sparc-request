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

RSpec.describe Dashboard::VisitsController do
  describe 'PUT #update' do
    context 'Valid visit params' do
      context 'user is editing visit on the Dashboard' do
        before :each do
          logged_in_user = create(:identity)
          log_in_dashboard_identity(obj: logged_in_user)

          org       = create(:organization)
          service   = create(:service, organization: org)
          @protocol = create(:protocol_federally_funded, primary_pi: logged_in_user)
          @sr       = create(:service_request_without_validations, protocol: @protocol)
          @ssr      = create(:sub_service_request, service_request: @sr, organization: org, status: 'approved')
          @arm      = create(:arm, protocol: @protocol)
          @vg       = create(:visit_group, arm: @arm)
          @li       = create(:line_item, service: service, service_request: @sr, sub_service_request: @ssr)
          @liv      = create(:line_items_visit, line_item: @li, arm: @arm)
          @visit    = create(:visit,
                             line_items_visit: @liv,
                             visit_group: @vg,
                             quantity: 1,
                             billing: 'R',
                             research_billing_qty: 0,
                             insurance_billing_qty: 0,
                             effort_billing_qty: 0)

          xhr :put, :update, {
            id: @visit.id,
            portal: 'true',
            service_request_id: @sr,
            visit: {
              research_billing_qty: 1
            }
          }
        end

        it 'should respond ok' do
          expect(controller).to respond_with(:ok)
        end

        it 'should render nothing' do
          expect(response.body).to be_blank
        end

        it 'should update the visit' do
          @visit.reload
          expect(@visit.research_billing_qty).to eq(1)
        end

        it 'should not set the status on the SSR to draft' do
          @ssr.reload
          expect(@ssr.status).to eq('approved')
        end
      end

      context 'user is editing visit in Proper' do
        before :each do
          logged_in_user = create(:identity)
          log_in_dashboard_identity(obj: logged_in_user)

          org       = create(:organization)
          service   = create(:service, organization: org)
          @protocol = create(:protocol_federally_funded, primary_pi: logged_in_user)
          @sr       = create(:service_request_without_validations, protocol: @protocol)
          @ssr      = create(:sub_service_request, service_request: @sr, organization: org, status: 'approved')
          @arm      = create(:arm, protocol: @protocol)
          @vg       = create(:visit_group, arm: @arm)
          @li       = create(:line_item, service: service, service_request: @sr, sub_service_request: @ssr)
          @liv      = create(:line_items_visit, line_item: @li, arm: @arm)
          @visit    = create(:visit,
                             line_items_visit: @liv,
                             visit_group: @vg,
                             quantity: 1,
                             billing: 'R',
                             research_billing_qty: 0,
                             insurance_billing_qty: 0,
                             effort_billing_qty: 0)

          xhr :put, :update, {
            id: @visit.id,
            portal: 'false',
            service_request_id: @sr,
            visit: {
              research_billing_qty: 1
            }
          }
        end

        it 'should respond ok' do
          expect(controller).to respond_with(:ok)
        end

        it 'should render nothing' do
          expect(response.body).to be_blank
        end

        it 'should update the visit' do
          @visit.reload
          expect(@visit.research_billing_qty).to eq(1)
        end

        it 'should set the status on the SSR to draft' do
          @ssr.reload
          expect(@ssr.status).to eq('draft')
        end
      end
    end

    context 'Invalid visit params' do
      before :each do
        before :each do
          logged_in_user = create(:identity)
          log_in_dashboard_identity(obj: logged_in_user)

          org       = create(:organization)
          service   = create(:service, organization: org)
          @protocol = create(:protocol_federally_funded, primary_pi: logged_in_user)
          @sr       = create(:service_request_without_validations, protocol: @protocol)
          @ssr      = create(:sub_service_request, service_request: @sr, organization: org, status: 'approved')
          @arm      = create(:arm, protocol: @protocol)
          @vg       = create(:visit_group, arm: @arm)
          @li       = create(:line_item, service: service, service_request: @sr, sub_service_request: @ssr)
          @liv      = create(:line_items_visit, line_item: @li, arm: @arm)
          @visit    = create(:visit,
                             line_items_visit: @liv,
                             visit_group: @vg,
                             quantity: 1,
                             billing: 'R',
                             research_billing_qty: 0,
                             insurance_billing_qty: 0,
                             effort_billing_qty: 0)

          xhr :put, :update, {
            id: @visit.id,
            portal: 'false',
            service_request_id: @sr,
            visit: {
              research_billing_qty: 1.5
            }
          }
        end

        it 'should respond with unprocessable_entity' do
          expect(controller).to respond_with(:unprocessable_entity)
        end

        it 'should not update the visit' do
          @visit.reload
          expect(@visit.research_billing_qty).to eq(0)
        end
      end
    end
  end
end