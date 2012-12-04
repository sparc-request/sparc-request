require 'spec_helper'

describe SearchController do
  stub_controller

  let!(:identity) { FactoryGirl.create(:identity) }
  let!(:institution) { FactoryGirl.create(:institution) }
  let!(:provider) { FactoryGirl.create(:provider, parent_id: institution.id) }
  let!(:program) { FactoryGirl.create(:program, parent_id: provider.id) }
  let!(:core) { FactoryGirl.create(:core, parent_id: program.id) }
  let!(:core2) { FactoryGirl.create(:core, parent_id: program.id) }

  let!(:service_request) { FactoryGirl.create(:service_request, visit_count: 0) }

  let!(:service1a) {
    service = FactoryGirl.create(
        :service,
        name: 'service1a',
        abbreviation: 'ser1a',
        description: 'this is service 1a',
        is_available: true,
        organization_id: core.id,
        pricing_map_count: 0)
    service
  }

  let!(:service1b) {
    service = FactoryGirl.create(
        :service,
        name: 'service1b',
        abbreviation: 'ser1b',
        description: 'this is service 1b',
        is_available: false,
        organization_id: core.id,
        pricing_map_count: 0)
    service
  }

  let!(:service2) {
    service = FactoryGirl.create(
        :service,
        name: 'service2',
        abbreviation: 'ser2',
        description: 'this is service 2',
        is_available: true,
        organization_id: core2.id,
        pricing_map_count: 0)
    service
  }

  let!(:service3) {
    service = FactoryGirl.create(
        :service,
        name: 'service3',
        abbreviation: 'ser3',
        description: 'this is service 3',
        is_available: true,
        organization_id: program.id,
        pricing_map_count: 0)
    service
  }

  describe 'GET services' do
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
  end

  describe 'GET identities' do
  end
end

