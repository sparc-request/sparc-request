require 'spec_helper'

describe SearchController do
  stub_controller

  describe 'GET services' do
    let!(:identity) { FactoryGirl.create(:identity) }
    let!(:institution) { FactoryGirl.create(:institution) }
    let!(:provider) { FactoryGirl.create(:provider, parent_id: institution.id) }
    let!(:program) { FactoryGirl.create(:program, parent_id: provider.id) }
    let!(:core) { FactoryGirl.create(:core, parent_id: program.id) }
    let!(:core2) { FactoryGirl.create(:core, parent_id: program.id) }
    let!(:unavailable_core) { FactoryGirl.create(:core, parent_id: program.id, is_available: false) }

    let!(:service_request) { FactoryGirl.create_without_validation(:service_request) }

    let!(:core_ssr) { FactoryGirl.create(:sub_service_request, service_request_id: service_request.id, organization_id: core.id) }
    let!(:core2_ssr) { FactoryGirl.create(:sub_service_request, service_request_id: service_request.id, organization_id: core2.id) }
    let!(:program_ssr) { FactoryGirl.create(:sub_service_request, service_request_id: service_request.id, organization_id: program.id) }
    let!(:provider_ssr) { FactoryGirl.create(:sub_service_request, service_request_id: service_request.id, organization_id: provider.id) }
    let!(:institution_ssr) { FactoryGirl.create(:sub_service_request, service_request_id: service_request.id, organization_id: institution.id) }
    let!(:unavailable_core_ssr) { FactoryGirl.create(:sub_service_request, service_request_id: service_request.id, organization_id: unavailable_core.id) }

    let!(:service1a) {
      service = FactoryGirl.create(
          :service,
          name: 'service1a',
          abbreviation: 'ser1a',
          description: 'this is service 1a',
          cpt_code: '123',
          organization_id: core.id)
      service
    }

    let!(:service1b) {
      service = FactoryGirl.create(
          :service,
          name: 'service1b',
          abbreviation: 'ser1b',
          description: 'this is service 1b',
          cpt_code: '352',
          organization_id: core.id)
      service
    }

    let!(:service2) {
      service = FactoryGirl.create(
          :service,
          name: 'service2',
          abbreviation: 'ser2',
          description: 'this is service 2',
          cpt_code: '987',
          organization_id: core2.id)
      service
    }

    let!(:service3) {
      service = FactoryGirl.create(
          :service,
          name: 'service3',
          abbreviation: 'ser3',
          description: 'this is service 3',
          organization_id: program.id)
      service
    }

    let!(:unavailable_service) {
      service = FactoryGirl.create(
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
        :format => :js,
        :id => nil,
        :term => 'service2',
      }.with_indifferent_access

      results = JSON.parse(response.body)

      parents = core2.parents.reverse + [ core2 ]

      results.count.should eq 1
      results[0]['parents'].should eq parents.map { |p| p.abbreviation }.join(' | ')
      results[0]['label'].should eq 'service2'
      results[0]['value'].should eq service2.id
      results[0]['description'].should eq 'this is service 2'
      results[0]['sr_id'].should eq service_request.id
    end

    it 'should find by cpt code' do
      session['service_request_id'] = service_request.id

      get :services, {
        :format => :js,
        :id => nil,
        :term => '123',
      }.with_indifferent_access

      results = JSON.parse(response.body)

      results.count.should eq 1
      results[0]['label'].should eq 'service1a'
      results[0]['value'].should eq service1a.id
      results[0]['description'].should eq 'this is service 1a'

    end

    it 'should return two services if two services match' do
      session['service_request_id'] = service_request.id

      get :services, {
        :format => :js,
        :id => nil,
        :term => 'service1',
      }.with_indifferent_access

      results = JSON.parse(response.body)

      results.count.should eq 2

      parents1 = core.parents.reverse + [ core ]
      results[0]['parents'].should eq parents1.map { |p| p.abbreviation }.join(' | ')
      results[0]['label'].should eq 'service1a'
      results[0]['value'].should eq service1a.id
      results[0]['description'].should eq 'this is service 1a'
      results[0]['sr_id'].should eq service_request.id

      parents2 = core.parents.reverse + [ core ]
      results[1]['parents'].should eq parents2.map { |p| p.abbreviation }.join(' | ')
      results[1]['label'].should eq 'service1b'
      results[1]['value'].should eq service1b.id
      results[1]['description'].should eq 'this is service 1b'
      results[1]['sr_id'].should eq service_request.id
    end

    it 'should return no results if no service matches' do
      session['service_request_id'] = service_request.id

      get :services, {
        :format => :js,
        :id => nil,
        :term => 'service5',
      }.with_indifferent_access

      results = JSON.parse(response.body)

      parents = core2.parents.reverse + [ core2 ]

      results.should eq [ { 'label' => 'No Results' } ]
    end

    it "should not return a service whose organization is not a parent of the sub service request's organization" do
      session['service_request_id'] = service_request.id
      session['sub_service_request_id'] = core_ssr.id

      get :services, {
        :format => :js,
        :id => nil,
        :term => 'service2', # service2's parent is core2
      }.with_indifferent_access

      results = JSON.parse(response.body)

      parents = core2.parents.reverse + [ core2 ]

      results.should eq [ { 'label' => 'No Results' } ]
    end

    it "should return a service whose organization is a parent of the sub service request's organization" do
      session['service_request_id'] = service_request.id
      session['sub_service_request_id'] = core2.id

      get :services, {
        :format => :js,
        :id => nil,
        :term => 'service2', # service2's parent is core2
      }.with_indifferent_access

      results = JSON.parse(response.body)

      parents = core2.parents.reverse + [ core2 ]

      results.count.should eq 1
      results[0]['parents'].should eq parents.map { |p| p.abbreviation }.join(' | ')
      results[0]['label'].should eq 'service2'
      results[0]['value'].should eq service2.id
      results[0]['description'].should eq 'this is service 2'
      results[0]['sr_id'].should eq service_request.id
    end

    it 'should not return a service that is not available' do
      session['service_request_id'] = service_request.id
      session['sub_service_request_id'] = unavailable_core_ssr.id

      get :services, {
        :format => :json,
        :id => nil,
        :term => 'unavailable_core',
      }.with_indifferent_access

      results = JSON.parse(response.body)

      results.should eq [ { 'label' => 'No Results' } ]
    end
  end

  describe 'GET identities' do
    let!(:identity) {
      identity = FactoryGirl.create(
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
      identity = FactoryGirl.create(
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

    it 'should return one instance if search returns one instance' do
      Identity.stub(:search) { [ identity ] }
      Identity.should_receive(:search).with('search term')

      get :identities, {
        :format => :json,
        :id => nil,
        :term => 'search term',
      }.with_indifferent_access

      results = JSON.parse(response.body)

      results.length.should eq 1

      results[0]['label'].should              eq 'Justin Frankel (burn@nullsoft.com)'
      results[0]['value'].should              eq identity.id
      results[0]['email'].should              eq 'burn@nullsoft.com'
      results[0]['institution'].should        eq 'Nullsoft'
      results[0]['phone'].should              eq '555-1212'
      results[0]['era_commons_name'].should   eq 'huh?'
      results[0]['college'].should            eq 'Winamp'
      results[0]['department'].should         eq 'Awesomeness'
      results[0]['credentials'].should        eq 'Master Hacker'
      results[0]['credentials_other'].should  eq 'Irc Junkie'
    end

    it 'should return two instances if search returns two instances' do
      Identity.stub(:search) { [ identity, identity2 ] }
      Identity.should_receive(:search).with('search term')

      get :identities, {
        :format => :json,
        :id => nil,
        :term => 'search term',
      }.with_indifferent_access

      results = JSON.parse(response.body)

      results.length.should eq 2

      results[0]['label'].should              eq 'Justin Frankel (burn@nullsoft.com)'
      results[0]['value'].should              eq identity.id
      results[0]['email'].should              eq 'burn@nullsoft.com'
      results[0]['institution'].should        eq 'Nullsoft'
      results[0]['phone'].should              eq '555-1212'
      results[0]['era_commons_name'].should   eq 'huh?'
      results[0]['college'].should            eq 'Winamp'
      results[0]['department'].should         eq 'Awesomeness'
      results[0]['credentials'].should        eq 'Master Hacker'
      results[0]['credentials_other'].should  eq 'Irc Junkie'

      # TODO: should this be "Mcafee" or "McAfee"?
      results[1]['label'].should              eq 'John Mcafee (john@mcafee.com)'
      results[1]['value'].should              eq identity2.id
      results[1]['email'].should              eq 'john@mcafee.com'
      results[1]['institution'].should        eq 'McAfee'
      results[1]['phone'].should              eq '867-5309'
      results[1]['era_commons_name'].should   eq 'wtf?'
      results[1]['college'].should            eq 'Roanoke College'
      results[1]['credentials'].should        eq 'Running from the authorities'
      results[1]['credentials_other'].should  eq 'Dangerous hobbies'
    end
  end
end

