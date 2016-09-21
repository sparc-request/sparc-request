# Copyright © 2011-2016 MUSC Foundation for Research Development
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

  describe 'GET services' do
    let!(:identity)             { create(:identity) }
    let!(:institution)          { create(:institution) }
    let!(:provider)             { create(:provider, parent_id: institution.id) }
    let!(:program)              { create(:program, parent_id: provider.id) }
    let!(:core)                 { create(:core, parent_id: program.id) }
    let!(:core2)                { create(:core, parent_id: program.id) }
    let!(:unavailable_core)     { create(:core, parent_id: program.id, is_available: false) }

    let!(:service_request)      { create(:service_request_without_validations) }

    let!(:core_ssr)             { create(:sub_service_request, service_request_id: service_request.id, organization_id: core.id) }
    let!(:core2_ssr)            { create(:sub_service_request, service_request_id: service_request.id, organization_id: core2.id) }
    let!(:program_ssr)          { create(:sub_service_request, service_request_id: service_request.id, organization_id: program.id) }
    let!(:provider_ssr)         { create(:sub_service_request, service_request_id: service_request.id, organization_id: provider.id) }
    let!(:institution_ssr)      { create(:sub_service_request, service_request_id: service_request.id, organization_id: institution.id) }
    let!(:unavailable_core_ssr) { create(:sub_service_request, service_request_id: service_request.id, organization_id: unavailable_core.id) }

    let!(:service1a) {
      service = create(
          :service,
          name: 'service1a',
          abbreviation: 'ser1a',
          description: 'this is service 1a',
          cpt_code: '123',
          organization_id: core.id)
      service
    }

    let!(:service1b) {
      service = create(
          :service,
          name: 'service1b',
          abbreviation: 'ser1b',
          description: 'this is service 1b',
          cpt_code: '352',
          organization_id: core.id)
      service
    }

    let!(:service2) {
      service = create(
          :service,
          name: 'service2',
          abbreviation: 'ser2',
          description: 'this is service 2',
          cpt_code: '987',
          organization_id: core2.id)
      service
    }

    let!(:service3) {
      service = create(
          :service,
          name: 'service3',
          abbreviation: 'ser3',
          description: 'this is service 3',
          organization_id: program.id)
      service
    }

    let!(:unavailable_service) {
      service = create(
          :service,
          name: 'unavailable service',
          abbreviation: 'unavail',
          description: 'this is an unavailable service',
          organization_id: unavailable_core.id)
      service
    }

    it 'should return one service if only one service matches' do
      session['service_request_id'] = service_request.id

      get :services, {
        format: :js,
        id: nil,
        term: 'service2',
      }.with_indifferent_access

      results = JSON.parse(response.body)

      parents = core2.parents.reverse + [ core2 ]

      expect(results.count).to eq 1
      expect(results[0]['parents']).to eq parents.map { |p| p.abbreviation }.join(' | ')
      expect(results[0]['label']).to eq 'service2'
      expect(results[0]['value']).to eq service2.id
      expect(results[0]['description']).to eq 'this is service 2'
      expect(results[0]['sr_id']).to eq service_request.id
    end

    it 'should find by cpt code' do
      session['service_request_id'] = service_request.id

      get :services, {
        format: :js,
        id: nil,
        term: '123',
      }.with_indifferent_access

      results = JSON.parse(response.body)

      expect(results.count).to eq 1
      expect(results[0]['label']).to eq 'service1a'
      expect(results[0]['value']).to eq service1a.id
      expect(results[0]['description']).to eq 'this is service 1a'

    end

    it 'should return two services if two services match' do
      session['service_request_id'] = service_request.id

      get :services, {
        format: :js,
        id: nil,
        term: 'service1',
      }.with_indifferent_access

      results = JSON.parse(response.body)

      expect(results.count).to eq 2

      parents1 = core.parents.reverse + [ core ]
      expect(results[0]['parents']).to eq parents1.map { |p| p.abbreviation }.join(' | ')
      expect(results[0]['label']).to eq 'service1a'
      expect(results[0]['value']).to eq service1a.id
      expect(results[0]['description']).to eq 'this is service 1a'
      expect(results[0]['sr_id']).to eq service_request.id

      parents2 = core.parents.reverse + [ core ]
      expect(results[1]['parents']).to eq parents2.map { |p| p.abbreviation }.join(' | ')
      expect(results[1]['label']).to eq 'service1b'
      expect(results[1]['value']).to eq service1b.id
      expect(results[1]['description']).to eq 'this is service 1b'
      expect(results[1]['sr_id']).to eq service_request.id
    end

    it 'should return no results if no service matches' do
      session['service_request_id'] = service_request.id

      get :services, {
        format: :js,
        id: nil,
        term: 'service5',
      }.with_indifferent_access

      results = JSON.parse(response.body)

      parents = core2.parents.reverse + [ core2 ]

      expect(results).to eq [ { 'label' => 'No Results' } ]
    end

    it "should not return a service whose organization is not a parent of the sub service request's organization" do
      session['service_request_id'] = service_request.id
      session['sub_service_request_id'] = core_ssr.id

      get :services, {
        format: :js,
        id: nil,
        term: 'service2', # service2's parent is core2
      }.with_indifferent_access

      results = JSON.parse(response.body)

      parents = core2.parents.reverse + [ core2 ]

      expect(results).to eq [ { 'label' => 'No Results' } ]
    end

    it "should return a service whose organization is a parent of the sub service request's organization" do
      session['service_request_id'] = service_request.id
      session['sub_service_request_id'] = core2_ssr.id

      get :services, {
        format: :js,
        id: nil,
        term: 'service2', # service2's parent is core2
      }.with_indifferent_access

      results = JSON.parse(response.body)

      parents = core2.parents.reverse + [ core2 ]

      expect(results.count).to eq 1
      expect(results[0]['parents']).to eq parents.map { |p| p.abbreviation }.join(' | ')
      expect(results[0]['label']).to eq 'service2'
      expect(results[0]['value']).to eq service2.id
      expect(results[0]['description']).to eq 'this is service 2'
      expect(results[0]['sr_id']).to eq service_request.id
    end

    it 'should not return a service that is not available' do
      session['service_request_id'] = service_request.id
      session['sub_service_request_id'] = unavailable_core_ssr.id

      get :services, {
        format: :json,
        id: nil,
        term: 'unavailable_core',
      }.with_indifferent_access

      results = JSON.parse(response.body)

      expect(results).to eq [ { 'label' => 'No Results' } ]
    end

    it 'should not return services which belong to a locked organization' do
      organization = create( :organization )
      ssr = create( :sub_service_request_without_validations,
                    organization: organization,
                    service_request: service_request,
                    status: 'on_hold' )
      service = create( :service,
                        organization: organization,
                        name: 'Super Specific Service Name and Number 1234567890' )
      EDITABLE_STATUSES[organization.id] = ['draft']

      session['service_request_id'] = service_request.id

      get :services, {
        format: :json,
        id: nil,
        term: service.name,
      }.with_indifferent_access

      results = JSON.parse(response.body)

      expect(results).to eq [ { 'label' => 'No Results' } ]
    end
  end

  describe 'GET identities' do
    let!(:identity) {
      identity = create(
          :identity,
          first_name:        'Justin',
          last_name:         'Frankel',
          ldap_uid:          '`burn',
          email:             'burn@nullsoft.com',
          institution:       'Nullsoft',
          phone:             '555-1212',
          era_commons_name:  'huh?',
          college:           'Winamp',
          department:        'Awesomeness',
          credentials:       'Master Hacker',
          credentials_other: 'Irc Junkie',
          )
      identity
    }

    let!(:identity2) {
      identity = create(
          :identity,
          first_name:        'John',
          last_name:         'McAfee',
          email:             'john@mcafee.com',
          institution:       'McAfee',
          phone:             '867-5309',
          era_commons_name:  'wtf?',
          college:           'Roanoke College',
          department:        'Scandalous',
          credentials:       'Running from the authorities',
          credentials_other: 'Dangerous hobbies',
          )
      identity
    }

    before(:each) do
      # shouldn't need to mess around with a ServiceRequest
      allow(controller).to receive(:initialize_service_request) {}
    end

    it 'should return one instance if search returns one instance' do
      allow(Identity).to receive(:search) { [ identity ] }
      expect(Identity).to receive(:search).with('search term')

      get :identities, {
        format: :json,
        id: nil,
        term: 'search term',
      }.with_indifferent_access

      results = JSON.parse(response.body)

      expect(results.length).to eq 1

      expect(results[0]['label']).to              eq 'Justin Frankel (burn@nullsoft.com)'
      expect(results[0]['value']).to              eq identity.id
      expect(results[0]['email']).to              eq 'burn@nullsoft.com'
      expect(results[0]['institution']).to        eq 'Nullsoft'
      expect(results[0]['phone']).to              eq '555-1212'
      expect(results[0]['era_commons_name']).to   eq 'huh?'
      expect(results[0]['college']).to            eq 'Winamp'
      expect(results[0]['department']).to         eq 'Awesomeness'
      expect(results[0]['credentials']).to        eq 'Master Hacker'
      expect(results[0]['credentials_other']).to  eq 'Irc Junkie'
    end

    it 'should return two instances if search returns two instances' do
      allow(Identity).to receive(:search) { [ identity, identity2 ] }
      expect(Identity).to receive(:search).with('search term')

      get :identities, {
        format: :json,
        id: nil,
        term: 'search term',
      }.with_indifferent_access

      results = JSON.parse(response.body)

      expect(results.length).to eq 2

      expect(results[0]['label']).to              eq 'Justin Frankel (burn@nullsoft.com)'
      expect(results[0]['value']).to              eq identity.id
      expect(results[0]['email']).to              eq 'burn@nullsoft.com'
      expect(results[0]['institution']).to        eq 'Nullsoft'
      expect(results[0]['phone']).to              eq '555-1212'
      expect(results[0]['era_commons_name']).to   eq 'huh?'
      expect(results[0]['college']).to            eq 'Winamp'
      expect(results[0]['department']).to         eq 'Awesomeness'
      expect(results[0]['credentials']).to        eq 'Master Hacker'
      expect(results[0]['credentials_other']).to  eq 'Irc Junkie'

      # TODO: should this be "Mcafee" or "McAfee"?
      expect(results[1]['label']).to              eq 'John Mcafee (john@mcafee.com)'
      expect(results[1]['value']).to              eq identity2.id
      expect(results[1]['email']).to              eq 'john@mcafee.com'
      expect(results[1]['institution']).to        eq 'McAfee'
      expect(results[1]['phone']).to              eq '867-5309'
      expect(results[1]['era_commons_name']).to   eq 'wtf?'
      expect(results[1]['college']).to            eq 'Roanoke College'
      expect(results[1]['credentials']).to        eq 'Running from the authorities'
      expect(results[1]['credentials_other']).to  eq 'Dangerous hobbies'
    end
  end
end
