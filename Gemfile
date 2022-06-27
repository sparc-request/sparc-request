source 'https://rubygems.org'

gem 'actionpack'
gem 'activerecord-import' # Use this more! In particular for arms/calendar creation
gem 'activeresource'
gem 'activerecord-session_store' # Check usage
gem 'acts_as_list', git: 'https://github.com/swanandp/acts_as_list.git'
gem 'acts-as-taggable-on', git: 'https://github.com/Fodoj/acts-as-taggable-on.git', branch: 'rails-5.2' # Consider updating to https://github.com/mbleigh/acts-as-taggable-on
gem 'audited', '~> 5.0'
gem 'axlsx', git: 'https://github.com/randym/axlsx', branch: 'master'
gem 'axlsx_rails'
gem 'babel-transpiler'
gem 'bluecloth' # Check usage
gem 'bootsnap', require: false
gem 'bootstrap-sass', '3.4.1' # Bootstrap 4 purge
gem 'bootstrap3-datetimepicker-rails' # Bootstrap 4 purge
gem 'bootstrap-toggle-rails' # Bootstrap 4 purge
gem 'capistrano', '~> 3.17'
gem 'capistrano-bundler', require: false
gem 'capistrano-rvm', require: false
gem 'capistrano-rails', require: false
gem 'capistrano-passenger', require: false
gem 'capistrano3-delayed-job', '~> 1.7'
gem 'coffee-rails'
gem 'country_select'
gem 'curb', '~> 1.0.1'
gem 'deep_cloneable', '~> 3.2.0'
gem 'delayed_job_active_record'
gem 'delayed_job'
gem 'devise', '~> 4.8'
gem 'doorkeeper' # OAuth application API authentication
gem 'dotenv-rails'
gem 'dynamic_form' # Check usage
gem 'execjs'
gem 'exception_notification'
gem 'font-awesome-sass'
gem 'filterrific', git: 'https://github.com/ayaman/filterrific.git'
gem 'grape', '1.5.3'
gem 'grape-entity', '~> 0.10.1'
gem 'grouped_validations', :git => 'https://github.com/jleonardw9/grouped_validations.git', branch: 'master'
gem 'gyoku' # Check usage
gem 'haml'
gem 'hashie-forbidden_attributes' # Check usage
gem 'httparty', '~> 0.20.0'
gem 'i18n-js'
gem 'icalendar'
gem 'icalendar-recurrence'
gem 'jquery_datepicker' # Check usage
gem 'jquery-rails' # Bootstrap 4 purge
gem 'jbuilder', '~> 2.11'
gem 'json', '>= 1.8'
gem 'letter_opener'
gem 'momentjs-rails', '>= 2.8.1' # Bootstrap 4 purge
gem 'mysql2', '0.5.3'
gem 'nested_form' # Check usage
gem 'nested_form_fields' # Check usage
gem 'newrelic_rpm' # Check usage
gem 'nokogiri'
gem 'nori' # Check usage
gem 'nprogress-rails' # Bootstrap 4 purge
gem 'net-ldap', '~> 0.17.1'
gem 'omniauth'
gem 'omniauth-cas'
gem 'omniauth-shibboleth'
gem 'omniauth-rails_csrf_protection'
gem 'paperclip', '~> 6.1' # Deprecated https://github.com/thoughtbot/paperclip
gem 'pdfkit'  # Check usage
gem 'prawn-table'
gem 'prawn', '2.4.0' # Check usage
gem 'premailer-rails'
gem 'puma', '~> 5.6'
gem 'rack-mini-profiler', require: false
gem 'rails', '5.2.8'
gem 'rails-html-sanitizer' # Check usage
gem "rails-observers", git: 'https://github.com/rails/rails-observers.git' # Needed to used audited-activerecord w/ Rails 5
gem 'redcarpet' # Check usage
gem 'rest-client' # Consider replacing usage with httparty
gem 'request_store'
gem 'sanitized_data',  git: 'https://github.com/HSSC/sanitized_data.git'
gem 'rubyzip', '>= 1.2.1'
gem 'sassc-rails'
gem 'savon', '~> 2.12.1'
gem 'slack-notifier'
gem 'sprockets', '~> 4.1'
gem 'twitter-typeahead-rails' # Bootstrap 4 purge
gem 'uglifier', '>= 1.3.0'
gem 'wash_out'
gem 'whenever', require: false
gem 'will_paginate'
gem 'will_paginate-bootstrap4'
gem 'x-editable-rails'

group :production do
end

group :development, :test, :profile do
  gem 'addressable', '~> 2.8.0' # Check usage
  gem 'bullet'
  gem 'connection_pool' # Check usage
  gem 'equivalent-xml' # Check usage
  gem 'faker'
  gem 'launchy' # Check usage
  gem 'timecop'
  gem 'progress_bar'
end

group :development, :test do
  gem 'byebug'
  gem 'email_spec' # Check usage
  gem 'factory_bot_rails'
  gem 'parallel_tests' # Check usage
  gem 'pdf-inspector', require: false
  gem 'pry'
  gem 'rails-controller-testing', require: false # Consider removing and cleaning up controller specs
  gem 'rails-erd' # Check usage
  gem 'rspec-activemodel-mocks' # Check usage
  gem 'rspec-collection_matchers'
  gem 'rspec-html-matchers' # Consider removing and using `have_selector` matchers
  gem 'rspec-rails', '~> 5.1'
  gem 'shoulda-callback-matchers'
  gem 'shoulda-matchers', require: false
  gem 'simplecov', require: false # Check usage
  gem 'site_prism'
  gem 'webdrivers', '~> 5.0'
  gem 'webmock'
  gem 'rspec-retry'
end

group :development do
  gem 'highline' # Check usage
  gem 'spring-commands-rspec' # Check usage
  gem 'spring'
  gem 'sqlite3' # Check usage
  gem 'traceroute' # Check usage
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
  gem 'ruby-prof', '~> 1.4.3' # Check usage
end
