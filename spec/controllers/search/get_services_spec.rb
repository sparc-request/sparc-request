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

RSpec.describe SearchController do
  stub_controller
  let!(:before_filters) { find_before_filters }
  let!(:logged_in_user) { create(:identity) }

  describe '#services' do
    it 'should call before_filter #initialize_service_request' do
      expect(before_filters.include?(:initialize_service_request)).to eq(true)
    end

    it 'should call before_filter #authorize_identity' do
      expect(before_filters.include?(:authorize_identity)).to eq(true)
    end

    it 'should return services with similar name' do
      sr    = create(:service_request_without_validations)
      inst  = create(:institution)
      prvdr = create(:provider, parent: inst)
      org   = create(:program, parent: prvdr)
      s1    = create(:service, organization: org, name: 'Serve me Well')
      s2    = create(:service, organization: org, name: 'Evres me Poorly')


      get :services, params: {
        service_request_id: sr.id,
        term: 'Serve'
      }, xhr: true

      results = JSON.parse(response.body)

      expect(results.count).to eq(1)
      expect(results[0]['value']).to eq(s1.id)

    end

    it 'should return services with similar abbreviation' do
      sr    = create(:service_request_without_validations)
      inst  = create(:institution)
      prvdr = create(:provider, parent: inst)
      org   = create(:program, parent: prvdr)
      s1    = create(:service, organization: org, abbreviation: 'Serve me Well')
      s2    = create(:service, organization: org, abbreviation: 'Evres me Poorly')

      get :services, params: {
        service_request_id: sr.id,
        term: 'Serve'
      }, xhr: true

      results = JSON.parse(response.body)

      expect(results.count).to eq(1)
      expect(results[0]['value']).to eq(s1.id)
    end

    it 'should return services with cpt code' do
      sr    = create(:service_request_without_validations)
      inst  = create(:institution)
      prvdr = create(:provider, parent: inst)
      org   = create(:program, parent: prvdr)
      s1    = create(:service, organization: org, cpt_code: 1234)
      s2    = create(:service, organization: org, cpt_code: 4321)


     get :services, params: {
        service_request_id: sr.id,
        term: '1234'
      }, xhr: true

      results = JSON.parse(response.body)

      expect(results.count).to eq(1)
      expect(results[0]['value']).to eq(s1.id)
    end

    it 'should not return unavailable services' do
      sr    = create(:service_request_without_validations)
      inst  = create(:institution)
      prvdr = create(:provider, parent: inst)
      org   = create(:program, parent: prvdr)
      s1    = create(:service, organization: org, name: 'Service 123', is_available: 1)
      s2    = create(:service, organization: org, name: 'Service 321', is_available: 0)


      get :services, params: {
        service_request_id: sr.id,
        term: 'Service'
      }, xhr: true

      results = JSON.parse(response.body)

      expect(results.count).to eq(1)
      expect(results[0]['value']).to eq(s1.id)
    end

    # Can we verify this?
    # it 'should not return services without a current pricing map' do
    # end

    it 'should not return services from a locked organization' do
      sr    = create(:service_request_without_validations)
      org   = create(:organization)
      inst  = create(:institution)
      prvdr = create(:provider, parent: inst)
      org2  = create(:program, parent: prvdr)
      ssr   = create(:sub_service_request_without_validations, service_request: sr, organization: org, status: 'on_hold')
      s1    = create(:service, organization: org, name: 'Service 123')
      s2    = create(:service, organization: org2, name: 'Service 321')

      org.editable_statuses.where(status: 'on_hold').destroy_all

      get :services, params: {
        service_request_id: sr.id,
        term: 'Service'
      }, xhr: true

      results = JSON.parse(response.body)

      expect(results.count).to eq(1)
      expect(results[0]['value']).to eq(s2.id)
    end

    context 'editing sub service request' do
      it 'should not return services which are not in the ssr\'s org tree' do
        sr    = create(:service_request_without_validations)
        inst  = create(:institution)
        prvdr = create(:provider, parent: inst)
        org   = create(:program, parent: prvdr)
        org2  = create(:organization)
        ssr   = create(:sub_service_request_without_validations, service_request: sr, organization: org)
        s1    = create(:service, organization: org, name: 'Service 123')
        s2    = create(:service, organization: org2, name: 'Service 321')

        get :services, params: {
          service_request_id: sr.id,
          sub_service_request_id: ssr.id,
          term: 'Service'
        }, xhr: true

        results = JSON.parse(response.body)

        expect(results.count).to eq(1)
        expect(results[0]['value']).to eq(s1.id)
      end
    end
  end
end
