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

require 'simplecov'
SimpleCov.start 'rails'
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
require 'capybara/email/rspec'
require 'selenium-webdriver'

# Add testing support for Paperclip
require 'paperclip/matchers'
RSpec.configure do |config|
  config.include Paperclip::Shoulda::Matchers
end

# Set default values for capybara; these can be overriden by a file in
# the support directory (see below).  For example, to use poltergeist,
# create file spec/support/poltergeist.rb that contains:
#
#   require 'capybara/poltergeist'
#   Capybara.javascript_driver = :poltergeist
#
# You can also enable firebug:
#
#   require 'capybara/firebug'
#   Capybara.javascript_driver = :selenium_with_firebug
#

profile = Selenium::WebDriver::Firefox::Profile.new

# Ensure that the change event is fired for text fields when the browser
# does not have the focus
# https://github.com/jnicklas/capybara/pull/951
profile['focusmanager.testmode'] = true

# Increase the max script run time.  The default (20/30) can cause
# failures on slow machines.  Disabling the check altogether (by setting
# to -1 secs) can cause the browser to hang altogether.
profile['dom.max_script_run_time'] = 60
profile['dom.max_chrome_script_run_time'] = 60

# Increase the amount of time before the page is re-rendered while the
# page is being loaded; this will decrease the total load time but make
# the rendering more "jumpy".
# http://kb.mozillazine.org/Content.notify.interval
# http://kb.mozillazine.org/Content.max.tokenizing.time
# http://kb.mozillazine.org/Nglayout.initialpaint.delay
profile['content.notify.ontimer'] = true
profile['content.notify.interval'] = 1000000 # µs
profile['content.max.tokenizing.time'] = 1000000 # µs
profile['nglayout.initialpaint.delay'] = 1000 # ms

# Enter low-frequency interrupt-handling mode more quickly (improves
# javascript performance at the expense of UI responsiveness during page
# load)
# http://kb.mozillazine.org/Content.switch.threshold
profile['content.switch.threshold'] = 100000 # µs

# Disable prefetch and increase total number of connections per server
# to improve page loading time
profile['network.http.max-connections-per-server'] = 30
profile['network.prefetch-next'] = false

# Set sqlite disk sync mode for the browser to "risky sync mode"
# (improves performance)
# http://kb.mozillazine.org/About:config_entries
profile['toolkit.storage.synchronous'] = 0

# Disable smooth scrolling
# http://kb.mozillazine.org/About:config_entries
profile['general.smoothScroll'] = false
profile['toolkit.scrollbox.smoothScroll'] = false

# TODO: try network.http.pipelining = true

Capybara.register_driver :default do |app|
  Capybara::Selenium::Driver.new(app, :browser => :firefox, :profile => profile)
end

Capybara.javascript_driver = :default
Capybara.default_wait_time = 15
Capybara.ignore_hidden_elements = true

# Requires supporting ruby files with custom matchers and macros, etc,
# in spec/support/ and its subdirectories.
Dir[Rails.root.join("spec/support/**/*.rb")].each {|f| require f}
include CapybaraSupport

# I'm not sure why this is necessary.  None of the examples at
# https://github.com/thoughtbot/factory_girl/blob/master/GETTING_STARTED.md
# seem to do this, but without it, we get the error "ArgumentError:
# Trait not registered: id".
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
  # silence_stream(STDOUT, &load_schema)
  load_schema.call
end

# We need to load the schema if we are using the in-memory sqlite3
# database; if we are using mysql, we can save some time by skipping
# this step.
ar_config = ActiveRecord::Base.configurations[Rails.env]
if ar_config['adapter'] == 'sqlite3' and ar_config['database'] == ':memory:' then
  load_schema()
end

FactoryGirl.find_definitions

RSpec.configure do |config|

  config.use_transactional_fixtures = false

  config.before(:suite) do
    # We can't use the transaction strategy with multiple threads, so we
    # use truncation instead.
    DatabaseCleaner.strategy = :truncation
    DatabaseCleaner.clean_with(:truncation)
  end

  config.before(:each) { DatabaseCleaner.start }
  config.after(:each) { DatabaseCleaner.clean }

  config.color_enabled = true

  config.after(:each) do
    # wait on all the push to epic calls to finish
    # TODO: ideally we should call Thread#join for all the 'push to
    # epic' threads
    Protocol.all.each do |protocol|
      while protocol.push_to_epic_in_progress? do
        sleep 0.1
        protocol.reload
      end
    end
  end
end

