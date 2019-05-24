source 'https://rubygems.org'

gem 'activerecord-import'
gem 'activeresource'
gem 'activerecord-session_store'
gem 'acts_as_list', :git => 'https://github.com/swanandp/acts_as_list.git'
gem 'acts-as-taggable-on', :git => 'https://github.com/Fodoj/acts-as-taggable-on.git', branch: 'rails-5.2'
gem 'audited', '~> 4.8'
gem 'axlsx', git: 'https://github.com/randym/axlsx', branch: 'master'
gem 'axlsx_rails'
gem 'bluecloth'
gem 'bootsnap', require: false
gem 'bootstrap-sass', '3.4.1'
gem 'sassc-rails', '>= 2.1.0'
gem 'bootstrap3-datetimepicker-rails'
gem 'bootstrap-toggle-rails'
gem 'capistrano', '~> 3.9'
gem 'capistrano-bundler', require: false
gem 'capistrano-rvm', require: false
gem 'capistrano-rails', require: false
gem 'capistrano-passenger', require: false
gem 'capistrano3-delayed-job', '~> 1.7'
gem 'coffee-rails'
gem 'country_select'
gem 'curb', '~> 0.9.9'
gem 'deep_cloneable', '~> 2.3.2'
gem 'delayed_job_active_record'
gem 'delayed_job'
gem 'devise', '~> 4.6'
gem 'dynamic_form'
gem 'execjs'
gem 'exception_notification'
gem 'filterrific', git: 'https://github.com/ayaman/filterrific.git'
gem 'gon', '~> 6.2'
gem 'grape', '1.1.0'
gem 'grape-entity', '~> 0.7.1'
gem 'grouped_validations', :git => 'https://github.com/jleonardw9/grouped_validations.git', branch: 'master'
gem 'gyoku'
gem 'haml'
gem 'hashie-forbidden_attributes'
gem 'httparty', '~> 0.16.2'
gem 'icalendar'
gem 'icalendar-recurrence'
gem 'jquery_datepicker'
gem 'jquery-rails'
gem 'jbuilder', '~> 2.8'
gem 'json', '>= 1.8'
gem 'letter_opener'
gem 'momentjs-rails', '>= 2.8.1'
gem 'mysql2', '~> 0.5'
gem 'nested_form'
gem 'nested_form_fields'
gem 'newrelic_rpm'
gem 'nokogiri'
gem 'nori'
gem 'nprogress-rails'
gem 'net-ldap', '~> 0.16.0'
gem 'omniauth'
gem 'omniauth-shibboleth'
gem 'paperclip', '~> 6.1'
gem 'pdfkit'
gem 'prawn', '0.12.0'
gem 'premailer-rails'
gem 'rack-mini-profiler', require: false
gem 'rails', '5.2.3'
gem 'rails-html-sanitizer'
# Needed to used audited-activerecord w/ Rails 5
gem "rails-observers", git: 'https://github.com/rails/rails-observers.git'
gem 'redcarpet'
gem 'remotipart'
gem 'rest-client'
gem 'request_store'
gem 'sanitized_data',  git: 'https://github.com/HSSC/sanitized_data.git'
gem 'rubyzip', '>= 1.2.1'
gem 'sass'
gem 'sass-rails'
gem 'savon', '~> 2.2.0'
gem 'simplecov', require: false, group: :test
gem 'slack-notifier'
gem 'therubyracer', '0.12.3', :platforms => :ruby, group: :production
gem 'twitter-typeahead-rails'
gem 'uglifier', '>= 1.0.3'
gem 'whenever', require: false
gem 'will_paginate'
gem 'will_paginate-bootstrap'
gem 'x-editable-rails'
gem 'omniauth-cas'
gem 'dotenv-rails'

group :development, :test, :profile do
  gem 'addressable', '~> 2.6.0'
  gem 'bullet'
  gem 'connection_pool'
  gem 'equivalent-xml'
  gem 'faker'
  gem 'launchy'
  gem 'timecop'
  gem 'progress_bar'
end
gem 'puma', '~> 3.12'

group :development, :test do
  gem 'pry'
  gem 'rails-erd'
  gem 'rspec-rails', '~> 3.8'
end

group :development do
  gem 'highline'
  gem 'spring-commands-rspec'
  gem 'byebug'
  gem 'spring'
  gem 'sqlite3'
  gem 'traceroute'
  gem 'parallel_tests', group: :development
end

group :test do
  gem 'database_cleaner'
  gem 'email_spec'
  gem "factory_bot_rails"
  gem 'geckodriver-helper'
  gem 'rails-controller-testing', require: false
  gem 'rspec-activemodel-mocks'
  gem 'rspec-html-matchers'
  gem 'selenium-webdriver'
  gem 'shoulda-matchers', require: false
  gem 'shoulda-callback-matchers'
  gem 'site_prism'
  gem 'webmock'
end

group :assets do
  # We don't require this because we only have it so
  # that we can run asset precompile during build without
  # connecting to a database
  # If we allow it to be required though it will screw up
  # schema load / migrations because monkey patching.
  # So what we do is not require it and then generate the
  # require statement in the database.yml that we generate
  # in the hab package build
  gem "activerecord-nulldb-adapter", require: false
end

group :profile do
  gem 'ruby-prof'
end
