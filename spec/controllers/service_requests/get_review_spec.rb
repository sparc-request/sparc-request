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

  describe '#review' do
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

    it 'should assign @tab to \'calendar\'' do
      org      = create(:organization)
      service  = create(:service, organization: org, one_time_fee: true)
      protocol = create(:protocol_federally_funded, primary_pi: logged_in_user)
      sr       = create(:service_request_without_validations, protocol: protocol)
      ssr      = create(:sub_service_request_without_validations, service_request: sr, organization: org)
      li       = create(:line_item, service_request: sr, sub_service_request: ssr, service: service)

      get :review, params: { srid: sr.id }, xhr: true

      expect(assigns(:tab)).to eq('calendar')
    end

    it 'should assign @review to true' do
      org      = create(:organization)
      service  = create(:service, organization: org, one_time_fee: true)
      protocol = create(:protocol_federally_funded, primary_pi: logged_in_user)
      sr       = create(:service_request_without_validations, protocol: protocol)
      ssr      = create(:sub_service_request_without_validations, service_request: sr, organization: org)
      li       = create(:line_item, service_request: sr, sub_service_request: ssr, service: service)

      get :review, params: { srid: sr.id }, xhr: true

      expect(assigns(:review)).to eq(true)
    end

    it 'should assign @portal to false' do
      org      = create(:organization)
      service  = create(:service, organization: org, one_time_fee: true)
      protocol = create(:protocol_federally_funded, primary_pi: logged_in_user)
      sr       = create(:service_request_without_validations, protocol: protocol)
      ssr      = create(:sub_service_request_without_validations, service_request: sr, organization: org)
      li       = create(:line_item, service_request: sr, sub_service_request: ssr, service: service)

      get :review, params: { srid: sr.id }, xhr: true

      expect(assigns(:portal)).to eq(false)
    end

    it 'should assign @merged to true' do
      org      = create(:organization)
      service  = create(:service, organization: org, one_time_fee: true)
      protocol = create(:protocol_federally_funded, primary_pi: logged_in_user)
      sr       = create(:service_request_without_validations, protocol: protocol)
      ssr      = create(:sub_service_request_without_validations, service_request: sr, organization: org)
      li       = create(:line_item, service_request: sr, sub_service_request: ssr, service: service)

      get :review, params: { srid: sr.id }, xhr: true

      expect(assigns(:merged)).to eq(true)
    end

    it 'should assign @consolidated to false' do
      org      = create(:organization)
      service  = create(:service, organization: org, one_time_fee: true)
      protocol = create(:protocol_federally_funded, primary_pi: logged_in_user)
      sr       = create(:service_request_without_validations, protocol: protocol)
      ssr      = create(:sub_service_request_without_validations, service_request: sr, organization: org)
      li       = create(:line_item, service_request: sr, sub_service_request: ssr, service: service)

      get :review, params: { srid: sr.id }, xhr: true

      expect(assigns(:consolidated)).to eq(false)
    end

    it 'should assign @pages' do
      org      = create(:organization)
      service  = create(:service, organization: org, one_time_fee: true)
      protocol = create(:protocol_federally_funded, primary_pi: logged_in_user)
      sr       = create(:service_request_without_validations, protocol: protocol)
      ssr      = create(:sub_service_request_without_validations, service_request: sr, organization: org)
      li       = create(:line_item, service_request: sr, sub_service_request: ssr, service: service)
      arm1     = create(:arm, protocol: protocol)
      arm2     = create(:arm, protocol: protocol)
      pages    = { arm1.id => 1, arm2.id => 1 }

      get :review, params: { srid: sr.id }, xhr: true

      expect(assigns(:pages)).to eq(pages)
    end

    it 'should render template' do
      org      = create(:organization)
      service  = create(:service, organization: org, one_time_fee: true)
      protocol = create(:protocol_federally_funded, primary_pi: logged_in_user)
      sr       = create(:service_request_without_validations, protocol: protocol)
      ssr      = create(:sub_service_request_without_validations, service_request: sr, organization: org)
      li       = create(:line_item, service_request: sr, sub_service_request: ssr, service: service)

      get :review, params: { srid: sr.id }, xhr: true

      expect(controller).to render_template(:review)
    end

    it 'should respond_with ok' do
      org      = create(:organization)
      service  = create(:service, organization: org, one_time_fee: true)
      protocol = create(:protocol_federally_funded, primary_pi: logged_in_user)
      sr       = create(:service_request_without_validations, protocol: protocol)
      ssr      = create(:sub_service_request_without_validations, service_request: sr, organization: org)
      li       = create(:line_item, service_request: sr, sub_service_request: ssr, service: service)

      get :review, params: { srid: sr.id }, xhr: true

      expect(controller).to respond_with(:ok)
    end
  end
end
