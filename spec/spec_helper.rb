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
require 'capybara/firebug'

# Set default values for capybara; these can be overriden by a file in
# the support directory (see below).  For example, to use poltergeist,
# create file spec/support.poltergeist.rb that contains:
#
#   require 'capybara/poltergeist'
#   Capybara.javascript_driver = :poltergeist
#
Capybara.javascript_driver = :selenium
Capybara.default_wait_time = 15

# Requires supporting ruby files with custom matchers and macros, etc,
# in spec/support/ and its subdirectories.
Dir[Rails.root.join("spec/support/**/*.rb")].each {|f| require f}
include CapybaraSupport

FactoryGirl.define do
  sequence :id do |id|
    id
  end
end

def load_schema
  load_schema = lambda {
    basedir = File.expand_path(File.dirname(__FILE__))
    load File.join(basedir, '../db/schema.rb')
  }
  silence_stream(STDOUT, &load_schema)
end

load_schema()
FactoryGirl.find_definitions

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
    load_schema()
    DatabaseCleaner.strategy = :transaction
    DatabaseCleaner.clean_with(:truncation)
  end

  before = proc do
    DatabaseCleaner.start
  end

  config.before(:each, :js => true, &before)
  config.before(:each, &before)

  config.after(:each) do
    DatabaseCleaner.clean
  end

  config.color_enabled = true
end

