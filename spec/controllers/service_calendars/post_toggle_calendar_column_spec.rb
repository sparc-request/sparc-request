# Copyright © 2011 MUSC Foundation for Research Development
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
# Copyright © 2011 MUSC Foundation for Research Development
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

  describe '#toggle_calendar_column' do
    it 'should call before_filter #initialize_service_request' do
      expect(before_filters.include?(:initialize_service_request)).to eq(true)
    end

    it 'should call before_filter #authorize_identity' do
      expect(before_filters.include?(:authorize_identity)).to eq(true)
    end

    it 'should assign @arm' do
      org       = create(:organization)
      service   = create(:service, organization: org)
      protocol  = create(:protocol_without_validations, primary_pi: logged_in_user)
      sr        = create(:service_request_without_validations, protocol: protocol, status: 'on_hold')
      ssr       = create(:sub_service_request_without_validations, organization: org, service_request: sr, status: 'on_hold')
      arm       = create(:arm, protocol: protocol)
      li        = create(:line_item, service_request: sr, sub_service_request: ssr, service: service)
      liv       = create(:line_items_visit, line_item: li, arm: arm)
      vg        = create(:visit_group, arm: arm)
      v         = create(:visit, line_items_visit: liv, visit_group: vg)

      session[:identity_id] = logged_in_user.id

      xhr :post, :toggle_calendar_column, {
        service_request_id: sr.id,
        arm_id: arm.id,
        check: 'true',
        portal: 'false'
      }

      expect(assigns(:arm)).to eq(arm)
    end

    it 'should assign @portal' do
      org       = create(:organization)
      service   = create(:service, organization: org)
      protocol  = create(:protocol_without_validations, primary_pi: logged_in_user)
      sr        = create(:service_request_without_validations, protocol: protocol, status: 'on_hold')
      ssr       = create(:sub_service_request_without_validations, organization: org, service_request: sr, status: 'on_hold')
      arm       = create(:arm, protocol: protocol)
      li        = create(:line_item, service_request: sr, sub_service_request: ssr, service: service)
      liv       = create(:line_items_visit, line_item: li, arm: arm)
      vg        = create(:visit_group, arm: arm)
      v         = create(:visit, line_items_visit: liv, visit_group: vg)

      session[:identity_id] = logged_in_user.id

      xhr :post, :toggle_calendar_column, {
        service_request_id: sr.id,
        arm_id: arm.id,
        check: 'true',
        portal: 'false'
      }

      expect(assigns(:portal)).to eq(false)
    end

    context 'check' do
      it 'should update visits' do
        org       = create(:organization)
        service   = create(:service, organization: org)
        protocol  = create(:protocol_without_validations, primary_pi: logged_in_user)
        sr        = create(:service_request_without_validations, protocol: protocol, status: 'on_hold')
        ssr       = create(:sub_service_request_without_validations, organization: org, service_request: sr, status: 'on_hold')
        arm       = create(:arm, protocol: protocol)
        li        = create(:line_item, service_request: sr, sub_service_request: ssr, service: service)
        liv       = create(:line_items_visit, line_item: li, arm: arm)
        vg        = create(:visit_group, arm: arm)
        v         = create(:visit, line_items_visit: liv, visit_group: vg, quantity: 0, research_billing_qty: 0, insurance_billing_qty: 1, effort_billing_qty: 1)

        session[:identity_id] = logged_in_user.id

        xhr :post, :toggle_calendar_column, {
        service_request_id: sr.id,
          arm_id: arm.id,
          check: 'true',
          portal: 'false'
        }

        expect(v.reload.quantity).to eq(1)
        expect(v.reload.research_billing_qty).to eq(1)
        expect(v.reload.insurance_billing_qty).to eq(0)
        expect(v.reload.effort_billing_qty).to eq(0)
      end
    end

    context 'uncheck' do
      it 'should update visits' do
        org       = create(:organization)
        service   = create(:service, organization: org)
        protocol  = create(:protocol_without_validations, primary_pi: logged_in_user)
        sr        = create(:service_request_without_validations, protocol: protocol, status: 'on_hold')
        ssr       = create(:sub_service_request_without_validations, organization: org, service_request: sr, status: 'on_hold')
        arm       = create(:arm, protocol: protocol)
        li        = create(:line_item, service_request: sr, sub_service_request: ssr, service: service)
        liv       = create(:line_items_visit, line_item: li, arm: arm)
        vg        = create(:visit_group, arm: arm)
        v         = create(:visit, line_items_visit: liv, visit_group: vg, quantity: 1, research_billing_qty: 1, insurance_billing_qty: 1, effort_billing_qty: 1)

        session[:identity_id] = logged_in_user.id

        xhr :post, :toggle_calendar_column, {
        service_request_id: sr.id,
          arm_id: arm.id,
          uncheck: 'true',
          portal: 'false'
        }

        expect(v.reload.quantity).to eq(0)
        expect(v.reload.research_billing_qty).to eq(0)
        expect(v.reload.insurance_billing_qty).to eq(0)
        expect(v.reload.effort_billing_qty).to eq(0)
      end
    end

    context 'not in dashboard' do
      it 'should update sub service requests statuses' do
        org       = create(:organization)
        service   = create(:service, organization: org)
        protocol  = create(:protocol_without_validations, primary_pi: logged_in_user)
        sr        = create(:service_request_without_validations, protocol: protocol, status: 'on_hold')
        ssr       = create(:sub_service_request_without_validations, organization: org, service_request: sr, status: 'on_hold')
        arm       = create(:arm, protocol: protocol)
        li        = create(:line_item, service_request: sr, sub_service_request: ssr, service: service)
        liv       = create(:line_items_visit, line_item: li, arm: arm)
        vg        = create(:visit_group, arm: arm)
        v         = create(:visit, line_items_visit: liv, visit_group: vg, quantity: 1, research_billing_qty: 1, insurance_billing_qty: 1, effort_billing_qty: 1)

        session[:identity_id] = logged_in_user.id

        xhr :post, :toggle_calendar_column, {
        service_request_id: sr.id,
          arm_id: arm.id,
          check: 'true',
          portal: 'false'
        }

        expect(ssr.reload.status).to eq('draft')
      end

      it 'should update service request status' do
        org       = create(:organization)
        service   = create(:service, organization: org)
        protocol  = create(:protocol_without_validations, primary_pi: logged_in_user)
        sr        = create(:service_request_without_validations, protocol: protocol, status: 'on_hold')
        ssr       = create(:sub_service_request_without_validations, organization: org, service_request: sr, status: 'on_hold')
        arm       = create(:arm, protocol: protocol)
        li        = create(:line_item, service_request: sr, sub_service_request: ssr, service: service)
        liv       = create(:line_items_visit, line_item: li, arm: arm)
        vg        = create(:visit_group, arm: arm)
        v         = create(:visit, line_items_visit: liv, visit_group: vg, quantity: 1, research_billing_qty: 1, insurance_billing_qty: 1, effort_billing_qty: 1)

        session[:identity_id] = logged_in_user.id

        xhr :post, :toggle_calendar_column, {
        service_request_id: sr.id,
          arm_id: arm.id,
          check: 'true',
          portal: 'false'
        }

        expect(sr.reload.status).to eq('draft')
      end

      context 'editing sub service request' do
        it 'should not update other sub service requests statuses' do
          org       = create(:organization)
          org2      = create(:organization)
          service   = create(:service, organization: org)
          protocol  = create(:protocol_without_validations, primary_pi: logged_in_user)
          sr        = create(:service_request_without_validations, protocol: protocol, status: 'on_hold')
          ssr       = create(:sub_service_request_without_validations, organization: org, service_request: sr, status: 'on_hold')
          ssr2      = create(:sub_service_request_without_validations, organization: org2, service_request: sr, status: 'on_hold')
          arm       = create(:arm, protocol: protocol)
          li        = create(:line_item, service_request: sr, sub_service_request: ssr, service: service)
          liv       = create(:line_items_visit, line_item: li, arm: arm)
          vg        = create(:visit_group, arm: arm)
          v         = create(:visit, line_items_visit: liv, visit_group: vg, quantity: 1, research_billing_qty: 1, insurance_billing_qty: 1, effort_billing_qty: 1)

          session[:identity_id] = logged_in_user.id

          xhr :post, :toggle_calendar_column, {
            sub_service_request_id: ssr.id,
            service_request_id: sr.id,
            arm_id: arm.id,
            check: 'true',
            portal: 'false'
          }

          expect(ssr.reload.status).to eq('draft')
          expect(ssr2.reload.status).to eq('on_hold')
        end
      end
    end

    it 'should render template' do
      org       = create(:organization)
      service   = create(:service, organization: org)
      protocol  = create(:protocol_without_validations, primary_pi: logged_in_user)
      sr        = create(:service_request_without_validations, protocol: protocol, status: 'on_hold')
      ssr       = create(:sub_service_request_without_validations, organization: org, service_request: sr, status: 'on_hold')
      arm       = create(:arm, protocol: protocol)
      li        = create(:line_item, service_request: sr, sub_service_request: ssr, service: service)
      liv       = create(:line_items_visit, line_item: li, arm: arm)
      vg        = create(:visit_group, arm: arm)
      v         = create(:visit, line_items_visit: liv, visit_group: vg)

      session[:identity_id] = logged_in_user.id

      xhr :post, :toggle_calendar_column, {
        service_request_id: sr.id,
        arm_id: arm.id,
        check: 'true',
        portal: 'false'
      }

      expect(controller).to render_template(partial: '_update_service_calendar')
    end

    it 'should respond ok' do
      org       = create(:organization)
      service   = create(:service, organization: org)
      protocol  = create(:protocol_without_validations, primary_pi: logged_in_user)
      sr        = create(:service_request_without_validations, protocol: protocol, status: 'on_hold')
      ssr       = create(:sub_service_request_without_validations, organization: org, service_request: sr, status: 'on_hold')
      arm       = create(:arm, protocol: protocol)
      li        = create(:line_item, service_request: sr, sub_service_request: ssr, service: service)
      liv       = create(:line_items_visit, line_item: li, arm: arm)
      vg        = create(:visit_group, arm: arm)
      v         = create(:visit, line_items_visit: liv, visit_group: vg)

      session[:identity_id] = logged_in_user.id

      xhr :post, :toggle_calendar_column, {
        service_request_id: sr.id,
        arm_id: arm.id,
        check: 'true',
        portal: 'false'
      }

      expect(controller).to respond_with(:ok)
    end
  end
end
