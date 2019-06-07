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

RSpec.describe ServiceRequestsController, type: :controller do
  stub_controller
  let!(:before_filters) { find_before_filters }
  let!(:logged_in_user) { create(:identity) }

  describe '#service_calendar' do
    it 'should call before_filter #initialize_service_request' do
      expect(before_filters.include?(:initialize_service_request)).to eq(true)
    end

    it 'should call before_filter #validate_step' do
      expect(before_filters.include?(:validate_step)).to eq(true)
    end

    it 'should call before_filter #setup_navigation' do
      expect(before_filters.include?(:setup_navigation)).to eq(true)
    end

    it 'should call before_filter #authorize_identity' do
      expect(before_filters.include?(:authorize_identity)).to eq(true)
    end

    it 'should call before_filter #authenticate_identity!' do
      expect(before_filters.include?(:authenticate_identity!)).to eq(true)
    end

    it 'should assign @has_subsidy' do
      org      = create(:organization)
                 create(:subsidy_map, organization: org, max_dollar_cap: 100, max_percentage: 100)
      service  = create(:service, organization: org)
      protocol = create(:protocol_federally_funded, primary_pi: logged_in_user)
      sr       = create(:service_request_without_validations, protocol: protocol)
      ssr      = create(:sub_service_request_without_validations, service_request: sr, organization: org)
      li       = create(:line_item, service_request: sr, sub_service_request: ssr, service: service)
      arm      = create(:arm, protocol: protocol)
                 create(:subsidy, sub_service_request: ssr)

      get :service_subsidy, params: { srid: sr.id }, xhr: true

      expect(assigns(:has_subsidy)).to eq(true)
    end

    it 'should assign @eligible_for_study' do
      org      = create(:organization)
                 create(:subsidy_map, organization: org, max_dollar_cap: 100, max_percentage: 100)
      service  = create(:service, organization: org)
      protocol = create(:protocol_federally_funded, primary_pi: logged_in_user)
      sr       = create(:service_request_without_validations, protocol: protocol)
      ssr      = create(:sub_service_request_without_validations, service_request: sr, organization: org)
      li       = create(:line_item, service_request: sr, sub_service_request: ssr, service: service)
      arm      = create(:arm, protocol: protocol)

      get :service_subsidy, params: { srid: sr.id }, xhr: true

      expect(assigns(:eligible_for_subsidy)).to eq(true)
    end

    context 'arms blank' do
      it 'should assign @back to service_details' do
        org      = create(:organization)
        service  = create(:service, organization: org, one_time_fee: true)
        protocol = create(:protocol_federally_funded, primary_pi: logged_in_user)
        sr       = create(:service_request_without_validations, protocol: protocol)
        ssr      = create(:sub_service_request_without_validations, service_request: sr, organization: org)
        li       = create(:line_item, service_request: sr, sub_service_request: ssr, service: service)

        get :service_subsidy, params: { srid: sr.id }, xhr: true
      end
    end

    it 'should redirect if !@has_subsidy && !@eligible_for_subsidy' do
      org      = create(:organization)
      service  = create(:service, organization: org)
      protocol = create(:protocol_federally_funded, primary_pi: logged_in_user)
      sr       = create(:service_request_without_validations, protocol: protocol)
      ssr      = create(:sub_service_request_without_validations, service_request: sr, organization: org)
      li       = create(:line_item, service_request: sr, sub_service_request: ssr, service: service)
      arm      = create(:arm, protocol: protocol)

      get :service_subsidy, params: { srid: sr.id }, xhr: true

      expect(controller).to redirect_to(document_management_service_request_path(srid: sr.id))
    end

    it 'should render template' do
      org      = create(:organization)
                 create(:subsidy_map, organization: org, max_dollar_cap: 100, max_percentage: 100)
      service  = create(:service, organization: org)
      protocol = create(:protocol_federally_funded, primary_pi: logged_in_user)
      sr       = create(:service_request_without_validations, protocol: protocol)
      ssr      = create(:sub_service_request_without_validations, service_request: sr, organization: org)
      li       = create(:line_item, service_request: sr, sub_service_request: ssr, service: service)
      arm      = create(:arm, protocol: protocol)

      get :service_subsidy, params: { srid: sr.id }, xhr: true

      expect(controller).to render_template(:service_subsidy)
    end

    it 'should respond ok' do
      org      = create(:organization)
                 create(:subsidy_map, organization: org, max_dollar_cap: 100, max_percentage: 100)
      service  = create(:service, organization: org)
      protocol = create(:protocol_federally_funded, primary_pi: logged_in_user)
      sr       = create(:service_request_without_validations, protocol: protocol)
      ssr      = create(:sub_service_request_without_validations, service_request: sr, organization: org)
      li       = create(:line_item, service_request: sr, sub_service_request: ssr, service: service)
      arm      = create(:arm, protocol: protocol)

      get :service_subsidy, params: { srid: sr.id }, xhr: true
    end
  end
end
