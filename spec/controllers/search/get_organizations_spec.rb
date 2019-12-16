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

RSpec.describe SearchController do
  stub_controller
  let!(:logged_in_user) { create(:identity) }

  describe '#services' do

    context 'input term is a name' do
      before :each do
        institution = create(:institution)
        provider = create(:provider, parent: institution)
        @program = create(:program, parent: provider)
      end

      it 'should return organizations with similar name' do
        core1 = create(:core, parent: @program, name: 'first core')
        core2 = create(:core, parent: @program, name: 'second core')

        get :organizations, params: {
          show_available_only: 'true',
          term: core1.name
        }, xhr: true

        results = JSON.parse(response.body)

        expect(results.count).to eq(1)
        expect(results[0]['name']).to eq(core1.name)
      end

      it 'should return services with similar name' do
        service1 = create(:service, organization: @program, name: 'first service')
        service2 = create(:service, organization: @program, name: 'second service')

        get :organizations, params: {
          show_available_only: 'true',
          term: service1.name
        }, xhr: true

        results = JSON.parse(response.body)

        expect(results.count).to eq(1)
        expect(results[0]['name']).to eq(service1.name)
      end
    end

    context 'input term is a abbreviation' do
      before :each do
        institution = create(:institution)
        provider = create(:provider, parent: institution)
        @program = create(:program, parent: provider)
      end

      it 'should return organizations with similar abbreviation' do
        core1 = create(:core, parent: @program, name: 'first core', abbreviation: 'first')
        core2 = create(:core, parent: @program, name: 'second core', abbreviation: 'second')

        get :organizations, params: {
          show_available_only: 'true',
          term: core1.abbreviation
        }, xhr: true

        results = JSON.parse(response.body)

        expect(results.count).to eq(1)
        expect(results[0]['name']).to eq(core1.name)
      end
      it 'should return services with similar abbreviation' do
        service1 = create(:service, organization: @program, name: 'first service', abbreviation: 'first')
        service2 = create(:service, organization: @program, name: 'second service', abbreviation: 'second')

        get :organizations, params: {
          show_available_only: 'true',
          term: service1.abbreviation
        }, xhr: true

        results = JSON.parse(response.body)

        expect(results.count).to eq(1)
        expect(results[0]['name']).to eq(service1.name)
      end
    end

    it 'should return services with cpt code' do
      sr    = create(:service_request_without_validations)
      inst  = create(:institution)
      prvdr = create(:provider, parent: inst)
      org   = create(:program, parent: prvdr)
      service1    = create(:service, organization: org, name: 'first service', cpt_code: 1234)
      service2    = create(:service, organization: org, name: 'second service', cpt_code: 4321)


     get :organizations, params: {
        show_available_only: 'true',
        term: '1234'
      }, xhr: true

      results = JSON.parse(response.body)

      expect(results.count).to eq(1)
      expect(results[0]['name']).to eq(service1.name)
    end

    it 'should not return unavailable organizations or services if showing available only' do
      institution = create(:institution)
      provider = create(:provider, parent: institution)
      program = create(:program, parent: provider)

      core1 = create(:core, parent: program, name: 'first core', is_available: true)
      core2 = create(:core, parent: program, name: 'second core', is_available: false)

      # show_available_only is what the state of the button is after the next click
      get :organizations, params: {
        show_available_only: 'true',
        term: 'core'
      }, xhr: true

      results = JSON.parse(response.body)

      expect(results.count).to eq(1)
      expect(results[0]['name']).to eq(core1.name)
    end

    it 'should return unavailable organizations or services if showing all' do
      institution = create(:institution)
      provider = create(:provider, parent: institution)
      program = create(:program, parent: provider)

      core1 = create(:core, parent: program, name: 'first core', is_available: true)
      core2 = create(:core, parent: program, name: 'second core', is_available: false)

      # show_available_only is what the state of the button is after the next click
      get :organizations, params: {
        show_available_only: 'false',
        term: 'core'
      }, xhr: true

      results = JSON.parse(response.body)

      expect(results.count).to eq(2)
    end

  end
end
