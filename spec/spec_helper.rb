# This file is copied to spec/ when you run 'rails generate rspec:install'
ENV["RAILS_ENV"] ||= 'test'
require File.expand_path("../../config/environment", __FILE__)
require 'rspec/rails'
require 'rspec/autorun'
require 'database_cleaner'
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

RSpec.configure do |config|

  config.before(:suite) do
    load_schema = lambda {
      load "schema.rb"
    }
    silence_stream(STDOUT, &load_schema)
    DatabaseCleaner.strategy = :transaction
    DatabaseCleaner.clean_with(:truncation)
  end
  
  config.before(:each) do
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

  config.after(:each) do
    DatabaseCleaner.clean
  end

end
