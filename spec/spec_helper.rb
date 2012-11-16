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

    institution = FactoryGirl.create(:institution,
      id:                   53,
      name:                 'Medical University of South Carolina',
      order:                1,
      obisid:               '87d1220c5abf9f9608121672be000412',
      abbreviation:         'MUSC', is_available:         1)
    institution.save!

    provider = FactoryGirl.create(:provider,
      id:                   10,
      name:                 'South Carolina Clinical and Translational Institute (SCTR)',
      order:                1,
      css_class:            'blue-provider',
      obisid:               '87d1220c5abf9f9608121672be0011ff',
      parent_id:            institution.id,
      abbreviation:         'SCTR1',
      process_ssrs:         0,
      is_available:         1)
    provider.save!

    program = FactoryGirl.create(:program,
      id:                   54,
      type:                 'Program',
      name:                 'Office of Biomedical Informatics',
      order:                1,
      obisid:               '87d1220c5abf9f9608121672be021963',
      parent_id:            provider.id,
      abbreviation:         'Informatics',
      process_ssrs:         0,
      is_available:         1)
    program.save!

    core = FactoryGirl.create(:core,
      id:                   33,
      type:                 'Core',
      name:                 'Clinical Data Warehouse',
      order:                1,
      obisid:               '179eae3982ab1e4047051381fb7b1610',
      parent_id:            program.id,
      abbreviation:         'Clinical Data Warehouse')
    core.save!

    service = FactoryGirl.create(:service,
      id:                   67,
      obisid:               '87d1220c5abf9f9608121672be03867a',
      name:                 'MUSC Research Data Request (CDW)',
      abbreviation:         'CDW',
      order:                1,
      cpt_code:             '',
      organization_id:      core.id)
    service.save!

    pricing_map = FactoryGirl.create(:pricing_map,
      service_id:                   67,
      unit_type:                    'Per Query',
      unit_factor:                  1,
      is_one_time_fee:              1,
      full_rate:                    0,
      exclude_from_indirect_cost:   0,
      unit_minimum:                 1)
    pricing_map.save!
  end

  config.before(:each, :js => true, &before)
  config.before(:each, &before)

  config.after(:each) do
    DatabaseCleaner.clean
  end
end
