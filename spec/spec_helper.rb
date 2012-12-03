# This file is copied to spec/ when you run 'rails generate rspec:install'
ENV["RAILS_ENV"] ||= 'test'
require File.expand_path("../../config/environment", __FILE__)
require 'rspec/rails'
require 'rspec/autorun'
# require 'database_cleaner'
require 'factory_girl'
require 'faker'

# Add this to load Capybara integration:
require 'capybara/rspec'
require 'capybara/rails'
require 'capybara/dsl'

# Requires supporting ruby files with custom matchers and macros, etc,
# in spec/support/ and its subdirectories.
# TODO: use rubygems to find the path to obis-bridge
FactoryGirl.definition_file_paths.append(
    File.expand_path('../../../obis-bridge/spec/factories', __FILE__))

FactoryGirl.define do
  sequence :id do |id|
    id
  end
end

FactoryGirl.find_definitions

Capybara.javascript_driver = :selenium
Capybara.default_wait_time = 10


class ActiveRecord::Base
  mattr_accessor :shared_connection
  @@shared_connection = nil


  def self.connection
    @@shared_connection || retrieve_connection
  end
end

# Forces all threads to share the same connection. This works on
# Capybara because it starts the web server in a thread.
ActiveRecord::Base.shared_connection = ActiveRecord::Base.connection

RSpec.configure do |config|

  config.before(:suite) do
    load_schema = lambda {
      load "schema.rb"
    }
    silence_stream(STDOUT, &load_schema)
    DatabaseCleaner.strategy = :transaction
    DatabaseCleaner.clean_with(:truncation)
  end


  
  before = proc do
    DatabaseCleaner.start

    identity = Identity.create(
      last_name:           'Glenn',
      first_name:          'Julia',
      ldap_uid:            'jug2',
      institution:         'medical_university_of_south_carolina',
      college:             'college_of_medecine',
      department:          'other',
      email:               'glennj@musc.edu',
      credentials:         'BS,    MRA',
      catalog_overlord:    true)
    identity.save!

  end

  config.before(:each, :js => true, &before)
  config.before(:each, &before)

  config.after(:each) do
    DatabaseCleaner.clean
  end
end

def build_service_request_with_project
  build_service_request()
  build_project()
end

def build_service_request_with_study
  build_service_request()
  build_study()
end

def build_service_request
  let!(:service_request) { FactoryGirl.create(:service_request, status: "draft", subject_count: 2, visit_count: 10) }
  let!(:institution)  {FactoryGirl.create(:institution,name: 'Medical University of South Carolina', order: 1,obisid: '87d1220c5abf9f9608121672be000412',abbreviation: 'MUSC', is_available: 1)}
  let!(:provider) {FactoryGirl.create(:provider,parent_id:institution.id,name: 'South Carolina Clinical and Translational Institute (SCTR)',order: 1,css_class: 'blue-provider',obisid: '87d1220c5abf9f9608121672be0011ff',abbreviation: 'SCTR1',process_ssrs: 0,is_available: 1)}
  let!(:program) {FactoryGirl.create(:program,type:'Program',parent_id:provider.id,name:'Office of Biomedical Informatics',order:1,obisid:'87d1220c5abf9f9608121672be021963',abbreviation:'Informatics',process_ssrs:  0,is_available: 1)}
  let!(:program2) {FactoryGirl.create(:program,type:'Program',parent_id:provider.id,name:'Office of Biomedical Informatics',order:1,obisid:'87d1220c5abf9f9608121672be021963',abbreviation:'Informatics',process_ssrs:  0,is_available: 1)}
  let!(:sub_service_request) { FactoryGirl.create(:sub_service_request, service_request_id: service_request.id, organization_id: program.id,status: "draft")}
  # One time fee service
  let!(:service)         { FactoryGirl.create(:service, organization_id:program.id) }
  let!(:line_item)       { FactoryGirl.create(:line_item, service_request_id: service_request.id, service_id: service.id, sub_service_request_id: sub_service_request.id, quantity: 5, units_per_quantity: 1) }
  let!(:pricing_setup)   {FactoryGirl.create(:pricing_setup, organization_id: program.id, display_date: Time.now - 1.day, federal: 50, corporate: 50, other: 50, member: 50, college_rate_type: 'federal', federal_rate_type: 'federal', industry_rate_type: 'federal', investigator_rate_type: 'federal', internal_rate_type: 'federal', foundation_rate_type: 'federal')}
  let!(:pricing_map)     { FactoryGirl.create(:pricing_map, unit_minimum: 1, unit_factor: 1, service_id: service.id, is_one_time_fee: true, display_date: Time.now - 1.day, full_rate: 2000) }
  # Per patient per visit service
  let!(:service2)        { FactoryGirl.create(:service, organization_id:program2.id) }
  let!(:line_item2)      { FactoryGirl.create(:line_item, service_request_id: service_request.id, service_id: service2.id, sub_service_request_id: sub_service_request.id) }
  let!(:pricing_setup2)  {FactoryGirl.create(:pricing_setup, organization_id: program2.id, display_date: Time.now - 1.day, federal: 150, corporate: 50, other: 50, member: 50, college_rate_type: 'federal', federal_rate_type: 'federal', industry_rate_type: 'federal', investigator_rate_type: 'federal', internal_rate_type: 'federal', foundation_rate_type: 'federal')}
  let!(:pricing_map2)    { FactoryGirl.create(:pricing_map, unit_minimum: 1, unit_factor: 1, service_id: service2.id, is_one_time_fee: false, display_date: Time.now - 1.day, full_rate: 2000) }

  before :each do
    service_request.update_attribute(:service_requester_id, Identity.find_by_ldap_uid("jug2").id)
  end
end

def add_visits
  (1..service_request.visit_count).each do
    FactoryGirl.create(:visit, line_item_id: line_item2.id, quantity: 0)
  end
end

def build_project
  before :each do
    protocol = Project.create(FactoryGirl.attributes_for(:protocol))
    protocol.update_attribute(:funding_status, "funded")
    protocol.update_attribute(:funding_source, "federal")
    protocol.save :validate => false
    FactoryGirl.create(:project_role, protocol_id: protocol.id, identity_id: Identity.find_by_ldap_uid("jug2"), project_rights: "approve", role: "pi")
    service_request.update_attribute(:protocol_id, protocol.id)
  end
end

def build_study
  before :each do
    protocol = Study.create(FactoryGirl.attributes_for(:protocol))
    protocol.update_attribute(:funding_status, "funded")
    protocol.update_attribute(:funding_source, "federal")
    protocol.save :validate => false
    FactoryGirl.create(:project_role, protocol_id: protocol.id, identity_id: Identity.find_by_ldap_uid("jug2"), project_rights: "approve", role: "pi")
    service_request.update_attribute(:protocol_id, protocol.id)
  end
end

