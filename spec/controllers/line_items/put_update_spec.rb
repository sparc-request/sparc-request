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

RSpec.describe LineItemsController, type: :controller do
  stub_controller
  let!(:before_filters) { find_before_filters }
  let!(:logged_in_user) { create(:identity) }

  describe '#update' do

    before :each do
      session[:identity_id] = logged_in_user.id
    end

    it 'should call before_filter #initialize_service_request' do
      expect(before_filters.include?(:initialize_service_request)).to eq(true)
    end

    it 'should call before_filter #authorize_identity' do
      expect(before_filters.include?(:authorize_identity)).to eq(true)
    end

    context 'line item valid' do
      it 'should update line item' do
        protocol  = create(:protocol_without_validations, primary_pi: logged_in_user)
        sr        = create(:service_request_without_validations, protocol: protocol)
        org       = create(:organization)
        ssr       = create(:sub_service_request_without_validations, service_request: sr, organization: org)
        service   = create(:service, one_time_fee: true, pricing_map_count: 1)
        li        = create(:line_item_without_validations, sub_service_request: ssr, quantity: 1, service: service, service_request: sr)
        li_params = { quantity: 2 }

        put :update, params: {
          id: li.id,
          srid: sr.id,
          line_item: li_params
        }, xhr: true

        expect(li.reload.quantity).to eq(2)
      end

      it 'should update service request status' do
        protocol  = create(:protocol_without_validations, primary_pi: logged_in_user, funding_status: 'funded', funding_source: 'federal')
        sr        = create(:service_request_without_validations, protocol: protocol, status: 'on_hold')
        org       = create(:organization)
        ssr       = create(:sub_service_request_without_validations, service_request: sr, organization: org, status: 'on_hold')
        service   = create(:service, one_time_fee: true, pricing_map_count: 1)
        li        = create(:line_item_without_validations, sub_service_request: ssr, service: service, service_request: sr)
        li_params = { quantity: 2 }

        put :update, params: {
          id: li.id,
          srid: sr.id,
          line_item: li_params
        }, xhr: true

        expect(sr.reload.status).to eq('draft')
      end

      it 'should update sub service request status' do
        protocol  = create(:protocol_without_validations, primary_pi: logged_in_user)
        sr        = create(:service_request_without_validations, protocol: protocol, status: 'on_hold')
        org       = create(:organization)
        ssr       = create(:sub_service_request_without_validations, service_request: sr, organization: org, status: 'on_hold')
        service   = create(:service, one_time_fee: true, pricing_map_count: 1)
        li        = create(:line_item_without_validations, sub_service_request: ssr, service: service, service_request: sr)
        li_params = { quantity: 2 }

        put :update, params: {
          id: li.id,
          srid: sr.id,
          line_item: li_params
        }, xhr: true

        expect(ssr.reload.status).to eq('draft')
      end

      it 'should render totals JSON' do
        protocol  = create(:protocol_without_validations, primary_pi: logged_in_user)
        sr        = create(:service_request_without_validations, protocol: protocol)
        org       = create(:organization)
        ssr       = create(:sub_service_request_without_validations, service_request: sr, organization: org)
        service   = create(:service, one_time_fee: true, pricing_map_count: 1)
        li        = create(:line_item_without_validations, sub_service_request: ssr, service: service, service_request: sr)
        li_params = { quantity: 2 }

        put :update, params: {
          id: li.id,
          srid: sr.id,
          line_item: li_params
        }, xhr: true

        json = JSON.parse(response.body)

        expect(json['total_per_study']).to be
        expect(json['max_total_direct']).to be
        expect(json['total_costs']).to be
      end

      it 'should respond ok' do
        protocol  = create(:protocol_without_validations, primary_pi: logged_in_user)
        sr        = create(:service_request_without_validations, protocol: protocol)
        org       = create(:organization)
        ssr       = create(:sub_service_request_without_validations, service_request: sr, organization: org)
        service   = create(:service, one_time_fee: true, pricing_map_count: 1)
        li        = create(:line_item_without_validations, sub_service_request: ssr, service: service, service_request: sr)
        li_params = { quantity: 2 }

        put :update, params: {
          id: li.id,
          srid: sr.id,
          line_item: li_params
        }, xhr: true

        expect(controller).to respond_with(:ok)
      end
    end

    context 'line item invalid' do
      it 'should render json errors' do
        protocol  = create(:protocol_without_validations, primary_pi: logged_in_user)
        sr        = create(:service_request_without_validations, protocol: protocol)
        org       = create(:organization)
        ssr       = create(:sub_service_request_without_validations, service_request: sr, organization: org)
        service   = create(:service, one_time_fee: true, pricing_map_count: 1)
        li        = create(:line_item_without_validations, sub_service_request: ssr, service: service, service_request: sr)
        li_params = { quantity: nil }

        put :update, params: {
          id: li.id,
          srid: sr.id,
          line_item: li_params
        }, xhr: true

        expect(JSON.parse(response.body)['quantity']).to be
      end

      it 'should respond unprocessable_entity' do
        protocol  = create(:protocol_without_validations, primary_pi: logged_in_user)
        sr        = create(:service_request_without_validations, protocol: protocol)
        org       = create(:organization)
        ssr       = create(:sub_service_request_without_validations, service_request: sr, organization: org)
        service   = create(:service, one_time_fee: true, pricing_map_count: 1)
        li        = create(:line_item_without_validations, sub_service_request: ssr, service: service, service_request: sr)
        li_params = { quantity: nil }

        put :update, params: {
          id: li.id,
          srid: sr.id,
          line_item: li_params
        }, xhr: true

        expect(controller).to respond_with(:unprocessable_entity)
      end
    end
  end
end
