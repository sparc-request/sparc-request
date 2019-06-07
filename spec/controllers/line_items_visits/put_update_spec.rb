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

RSpec.describe LineItemsVisitsController, type: :controller do
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

    it 'should call #authorize_dashboard_access' do
      expect(before_filters.include?(:authorize_dashboard_access)).to eq(true)
    end

    context 'line_items_visit valid' do
      it 'should update line_items_visit' do
        protocol    = create(:protocol_without_validations, primary_pi: logged_in_user)
        sr          = create(:service_request_without_validations, protocol: protocol)
        ssr         = create(:sub_service_request_without_validations, service_request: sr, organization: create(:organization))
        li          = create(:line_item_without_validations, sub_service_request: ssr, service: create(:service), service_request: sr)
        arm         = create(:arm, protocol: protocol, subject_count: 5)
        liv         = arm.line_items_visits.first
        liv_params  = { subject_count: 3 }

        put :update, params: {
          id: liv.id,
          service_request_id: sr.id,
          page: '1',
          line_items_visit: liv_params
        }, xhr: true

        expect(liv.reload.subject_count).to eq(3)
      end

      context 'in dashboard' do
        it 'should render totals partials and SSR header as JSON' do
          protocol    = create(:protocol_without_validations, primary_pi: logged_in_user)
          sr          = create(:service_request_without_validations, protocol: protocol)
          ssr         = create(:sub_service_request_without_validations, service_request: sr, organization: create(:organization))
          li          = create(:line_item_without_validations, sub_service_request: ssr, service: create(:service), service_request: sr)
          arm         = create(:arm, protocol: protocol, subject_count: 5)
          liv         = arm.line_items_visits.first
          liv_params  = { subject_count: 3 }

          put :update, params: {
            id: liv.id,
            service_request_id: sr.id,
            page: '1',
            portal: 'true',
            line_items_visit: liv_params
          }, xhr: true

          json = JSON.parse(response.body)
          
          expect(json['total_per_patient']).to be
          expect(json['total_per_study']).to be
          expect(json['max_total_direct']).to be
          expect(json['max_total_per_patient']).to be
          expect(json['total_costs']).to be
          expect(json['ssr_header']).to be
        end
      end

      context 'not in dashboard' do
        it 'should render totals partials but not SSR header as JSON' do
          protocol    = create(:protocol_without_validations, primary_pi: logged_in_user)
          sr          = create(:service_request_without_validations, protocol: protocol)
          ssr         = create(:sub_service_request_without_validations, service_request: sr, organization: create(:organization))
          li          = create(:line_item_without_validations, sub_service_request: ssr, service: create(:service), service_request: sr)
          arm         = create(:arm, protocol: protocol, subject_count: 5)
          liv         = arm.line_items_visits.first
          liv_params  = { subject_count: 3 }

          put :update, params: {
            id: liv.id,
            service_request_id: sr.id,
            page: '1',
            portal: 'false',
            line_items_visit: liv_params
          }, xhr: true

          json = JSON.parse(response.body)
          
          expect(json['total_per_patient']).to be
          expect(json['total_per_study']).to be
          expect(json['max_total_direct']).to be
          expect(json['max_total_per_patient']).to be
          expect(json['total_costs']).to be
          expect(json['ssr_header']).to_not be
        end
      end
    end

    context 'line_items_visit invalid' do
      it 'should render json errors' do
        protocol    = create(:protocol_without_validations, primary_pi: logged_in_user)
        sr          = create(:service_request_without_validations, protocol: protocol)
        ssr         = create(:sub_service_request_without_validations, service_request: sr, organization: create(:organization))
        li          = create(:line_item_without_validations, sub_service_request: ssr, service: create(:service), service_request: sr)
        arm         = create(:arm, protocol: protocol)
        liv         = arm.line_items_visits.first
        liv_params  = { subject_count: nil }

        put :update, params: {
          id: liv.id,
          service_request_id: sr.id,
          page: '1',
          line_items_visit: liv_params
        }, xhr: true

        expect(JSON.parse(response.body)['subject_count']).to be
      end

      it 'should respond unprocessable_entity' do
        protocol    = create(:protocol_without_validations, primary_pi: logged_in_user)
        sr          = create(:service_request_without_validations, protocol: protocol)
        ssr         = create(:sub_service_request_without_validations, service_request: sr, organization: create(:organization))
        li          = create(:line_item_without_validations, sub_service_request: ssr, service: create(:service), service_request: sr)
        arm         = create(:arm, protocol: protocol)
        liv         = arm.line_items_visits.first
        liv_params  = { subject_count: nil }

        put :update, params: {
          id: liv.id,
          service_request_id: sr.id,
          page: '1',
          line_items_visit: liv_params
        }, xhr: true

        expect(controller).to respond_with(:unprocessable_entity)
      end
    end
  end
end
