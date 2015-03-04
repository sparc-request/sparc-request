source 'https://rubygems.org'

gem 'rails', '3.2.11'

gem 'mysql2'
gem 'haml'
gem 'redcarpet'
gem 'bluecloth'
gem 'sass'

gem 'cache_digests'
gem 'dynamic_form'
gem 'jquery_datepicker'

gem 'json'
gem 'sinatra'
gem 'grouped_validations'
gem 'obis-net-ldap'
gem 'paperclip'
gem 'acts_as_list', '0.1.9'
gem 'devise'
gem 'omniauth'
gem 'omniauth-shibboleth'

gem "nested_form"
gem 'jquery-rails', "2.1.3"

gem 'will_paginate'

# requirements for excel export
gem 'axlsx'
gem 'axlsx_rails'

# Deploy with Capistrano
gem 'capistrano'
gem 'capistrano-ext'
gem 'rvm-capistrano', require: false

gem 'exception_notification'
gem 'letter_opener'

gem 'prawn'
gem "pdfkit"
gem 'acts-as-taggable-on', '~> 2.3.1'

gem 'savon', '~> 2.2.0'    # SOAP client
gem 'gyoku'                # XML builder
gem 'nori', '~> 2.1.0'     # XML parser

gem "audited-activerecord", "~> 3.0"

gem 'surveyor'

gem 'simplecov', :require => false, :group => :test
gem 'icalendar'

gem 'activerecord-import'
gem 'grape', '0.7.0'
gem 'grape-entity', '~> 0.4.4'
gem 'rest-client'
gem 'delayed_job_active_record'

group :development, :test, :profile do
  gem 'bullet'
  gem "rails-erd"
  gem 'sqlite3'
  gem 'rspec'
  gem 'rspec-rails'
  gem 'shoulda-matchers'
  gem 'launchy'
  gem 'capybara', '~> 2.0.2' # TODO: capybara 2.1 breaks our tests
  gem 'database_cleaner'
  gem 'factory_girl'
  gem 'faker'
  gem 'timecop'
  gem 'debugger'
  gem 'quiet_assets'
  gem 'connection_pool'
  gem 'thin'
  gem 'equivalent-xml'
  gem 'turn', :require => false
  gem 'addressable', '~> 2.3.6'
  gem 'watchr'
  gem 'capybara-firebug'
  gem 'capybara-email'
  gem 'selenium-webdriver', '~> 2.34.0'


  # You can put gems in here that you want to use for development but
  # don't want to force on other developers (e.g. rubyception).
  if File.exists?('Gemfile.devel') then
    eval File.read('Gemfile.devel'), nil, 'Gemfile.devel'
  end
end

group 'test' do
  # Add dependency on poltergeist.  If you want to use poltergeist, you
  # will need to configure Capybara to use it.  This particular
  # poltergeist repository is for Capybara 2.0 support.  Poltergeist
  # should official support Capybara 2.0 after Dec. 20.
  gem 'poltergeist' #, :git => 'git://github.com/brutuscat/poltergeist.git'
  gem 'webmock', '~> 1.20.4'
  gem 'shoulda-callback-matchers', '~> 1.1.1'
end

group :development do
  gem 'highline'
  gem 'spring'
  gem "spring-commands-rspec"
  gem "rspec-instafail"
end

group :profile do
  gem 'ruby-prof'
end

# these are needed for the import script
group :import do
  # gem 'alfresco_handler', :path => '../alfresco_handler'
  gem 'progress_bar'
  gem 'mustache'
end

# Gems used only for assets and not required
# in production environments by default.
group :assets do
  gem 'sass-rails',   '~> 3.2.3'
  gem 'coffee-rails', '~> 3.2.1'

  # See https://github.com/sstephenson/execjs#readme for more supported runtimes
  # gem 'therubyracer', :platforms => :ruby

  gem 'uglifier', '>= 1.0.3'
  gem 'inflection-js-rails'
end

gem 'newrelic_rpm'
