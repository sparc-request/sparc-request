# Copyright © 2011-2019 MUSC Foundation for Research Development
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

RSpec.describe ServiceCalendarsController do
  stub_controller
  let!(:before_filters) { find_before_filters }
  let!(:logged_in_user) { create(:identity) }

  describe '#toggle_calendar_row' do
    context 'check' do
      it 'should update visits' do
        org       = create(:organization)
        service   = create(:service, pricing_map_count: 1)
        protocol  = create(:protocol_without_validations, primary_pi: logged_in_user)
        sr        = create(:service_request_without_validations, protocol: protocol)
        ssr       = create(:sub_service_request_without_validations, organization: org, service_request: sr)
        li        = create(:line_item, service_request: sr, sub_service_request: ssr, service: service)
        arm       = create(:arm, protocol: protocol)
        liv       = arm.line_items_visits.first
        v         = arm.visits.first

        v.update_attributes(quantity: 0, research_billing_qty: 0, insurance_billing_qty: 1, effort_billing_qty: 1)

        session[:identity_id] = logged_in_user.id

        post :toggle_calendar_row, params: {
          line_items_visit_id: liv.id,
          service_request_id: sr.id,
          page: '1',
          check: 'true'
        }, xhr: true

        expect(v.reload.quantity).to eq(1)
        expect(v.reload.research_billing_qty).to eq(1)
        expect(v.reload.insurance_billing_qty).to eq(0)
        expect(v.reload.effort_billing_qty).to eq(0)
      end
    end

    context 'uncheck' do
      it 'should update visits' do
        org       = create(:organization)
        service   = create(:service, pricing_map_count: 1)
        protocol  = create(:protocol_without_validations, primary_pi: logged_in_user)
        sr        = create(:service_request_without_validations, protocol: protocol, status: 'on_hold')
        ssr       = create(:sub_service_request_without_validations, organization: org, service_request: sr, status: 'on_hold')
        arm       = create(:arm, protocol: protocol)
        li        = create(:line_item, service_request: sr, sub_service_request: ssr, service: service)
        liv       = create(:line_items_visit, line_item: li, arm: arm)
        vg        = create(:visit_group, arm: arm)
        v         = create(:visit, line_items_visit: liv, visit_group: vg, quantity: 1, research_billing_qty: 1, insurance_billing_qty: 1, effort_billing_qty: 1)

        session[:identity_id] = logged_in_user.id

        post :toggle_calendar_row, params: {
          service_request_id: sr.id,
          line_items_visit_id: liv.id,
          page: '1',
          uncheck: 'true',
        }, xhr: true

        expect(v.reload.quantity).to eq(0)
        expect(v.reload.research_billing_qty).to eq(0)
        expect(v.reload.insurance_billing_qty).to eq(0)
        expect(v.reload.effort_billing_qty).to eq(0)
      end
    end

    context '@admin false' do
      it 'should update sub service request to draft' do
        org       = create(:organization)
        service   = create(:service, pricing_map_count: 1)
        protocol  = create(:protocol_without_validations, primary_pi: logged_in_user)
        sr        = create(:service_request_without_validations, protocol: protocol, status: 'on_hold')
        ssr       = create(:sub_service_request_without_validations, organization: org, service_request: sr, status: 'on_hold')
        arm       = create(:arm, protocol: protocol)
        li        = create(:line_item, service_request: sr, sub_service_request: ssr, service: service)
        liv       = create(:line_items_visit, line_item: li, arm: arm)
        vg        = create(:visit_group, arm: arm)
        v         = create(:visit, line_items_visit: liv, visit_group: vg)

        session[:identity_id] = logged_in_user.id

        post :toggle_calendar_row, params: {
          service_request_id: sr.id,
          line_items_visit_id: liv.id,
          page: '1',
          check: 'true',
          admin: 'false'
        }, xhr: true

        expect(ssr.reload.status).to eq('draft')
      end
    end

    context '@admin true' do
      it 'should not update sub service requests to draft' do
        org       = create(:organization)
        service   = create(:service, pricing_map_count: 1)
        protocol  = create(:protocol_without_validations, primary_pi: logged_in_user)
        sr        = create(:service_request_without_validations, protocol: protocol, status: 'on_hold')
        ssr       = create(:sub_service_request_without_validations, organization: org, service_request: sr, status: 'on_hold')
        arm       = create(:arm, protocol: protocol)
        li        = create(:line_item, service_request: sr, sub_service_request: ssr, service: service)
        liv       = create(:line_items_visit, line_item: li, arm: arm)
        vg        = create(:visit_group, arm: arm)
        v         = create(:visit, line_items_visit: liv, visit_group: vg)

        session[:identity_id] = logged_in_user.id

        post :toggle_calendar_row, params: {
          service_request_id: sr.id,
          line_items_visit_id: liv.id,
          page: '1',
          check: 'true',
          admin: 'true'
        }, xhr: true

        expect(ssr.reload.status).to eq('on_hold')
      end
    end
  end
end
