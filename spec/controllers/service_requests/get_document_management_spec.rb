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

RSpec.describe ServiceRequestsController, type: :controller do
  stub_controller
  let!(:before_filters) { find_before_filters }
  let!(:logged_in_user) { create(:identity) }

  describe '#document_management' do
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

    it 'should assign @notable_type' do
      org      = create(:organization)
                 create(:subsidy_map, organization: org, max_dollar_cap: 100, max_percentage: 100)
      service  = create(:service, organization: org)
      protocol = create(:protocol_federally_funded, primary_pi: logged_in_user)
      sr       = create(:service_request_without_validations, protocol: protocol)
      ssr      = create(:sub_service_request_without_validations, service_request: sr, organization: org)
      li       = create(:line_item, service_request: sr, sub_service_request: ssr, service: service)
      arm      = create(:arm, protocol: protocol)
      liv      = create(:line_items_visit, arm: arm, line_item: li)
      vg       = create(:visit_group, arm: arm, day: 1)
                 create(:visit, visit_group: vg, line_items_visit: liv)
                 create(:subsidy, sub_service_request: ssr)

      xhr :get, :document_management, {
        id: sr.id
      }

      expect(assigns(:notable_type)).to eq('Protocol')
    end

    it 'should assign @notable_id' do
      org      = create(:organization)
                 create(:subsidy_map, organization: org, max_dollar_cap: 100, max_percentage: 100)
      service  = create(:service, organization: org)
      protocol = create(:protocol_federally_funded, primary_pi: logged_in_user)
      sr       = create(:service_request_without_validations, protocol: protocol)
      ssr      = create(:sub_service_request_without_validations, service_request: sr, organization: org)
      li       = create(:line_item, service_request: sr, sub_service_request: ssr, service: service)
      arm      = create(:arm, protocol: protocol)
      liv      = create(:line_items_visit, arm: arm, line_item: li)
      vg       = create(:visit_group, arm: arm, day: 1)
                 create(:visit, visit_group: vg, line_items_visit: liv)
                 create(:subsidy, sub_service_request: ssr)

      xhr :get, :document_management, {
        id: sr.id
      }

      expect(assigns(:notable_id)).to eq(protocol.id)
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
      liv      = create(:line_items_visit, arm: arm, line_item: li)
      vg       = create(:visit_group, arm: arm, day: 1)
                 create(:visit, visit_group: vg, line_items_visit: liv)
                 create(:subsidy, sub_service_request: ssr)

      xhr :get, :document_management, {
        id: sr.id
      }

      expect(assigns(:has_subsidy)).to eq(true)
    end

    it 'should assign @eligible_for_subsidy' do
      org      = create(:organization)
                 create(:subsidy_map, organization: org, max_dollar_cap: 100, max_percentage: 100)
      service  = create(:service, organization: org)
      protocol = create(:protocol_federally_funded, primary_pi: logged_in_user)
      sr       = create(:service_request_without_validations, protocol: protocol)
      ssr      = create(:sub_service_request_without_validations, service_request: sr, organization: org)
      li       = create(:line_item, service_request: sr, sub_service_request: ssr, service: service)
      arm      = create(:arm, protocol: protocol)
      liv      = create(:line_items_visit, arm: arm, line_item: li)
      vg       = create(:visit_group, arm: arm, day: 1)
                 create(:visit, visit_group: vg, line_items_visit: liv)

      xhr :get, :document_management, {
        id: sr.id
      }

      expect(assigns(:eligible_for_subsidy)).to eq(true)
    end

    context '!@has_subsidy && !@eligible_for_subidy' do
      it 'should assign @back to \'service_calendar\'' do
        org      = create(:organization)
        service  = create(:service, organization: org, one_time_fee: true)
        protocol = create(:protocol_federally_funded, primary_pi: logged_in_user)
        sr       = create(:service_request_without_validations, protocol: protocol)
        ssr      = create(:sub_service_request_without_validations, service_request: sr, organization: org)
        li       = create(:line_item, service_request: sr, sub_service_request: ssr, service: service)

        xhr :get, :document_management, {
          id: sr.id
        }

        expect(assigns(:back)).to eq('service_calendar')
      end
    end

    it 'should render template' do
      org      = create(:organization)
      service  = create(:service, organization: org, one_time_fee: true)
      protocol = create(:protocol_federally_funded, primary_pi: logged_in_user)
      sr       = create(:service_request_without_validations, protocol: protocol)
      ssr      = create(:sub_service_request_without_validations, service_request: sr, organization: org)
      li       = create(:line_item, service_request: sr, sub_service_request: ssr, service: service)

      xhr :get, :document_management, {
        id: sr.id
      }

      expect(controller).to render_template(:document_management)
    end

    it 'should respond ok' do
      org      = create(:organization)
      service  = create(:service, organization: org, one_time_fee: true)
      protocol = create(:protocol_federally_funded, primary_pi: logged_in_user)
      sr       = create(:service_request_without_validations, protocol: protocol)
      ssr      = create(:sub_service_request_without_validations, service_request: sr, organization: org)
      li       = create(:line_item, service_request: sr, sub_service_request: ssr, service: service)

      xhr :get, :document_management, {
        id: sr.id
      }

      expect(controller).to respond_with(:ok)
    end
  end
end
