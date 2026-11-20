source 'https://rubygems.org'

gem "abbrev"
gem 'actionpack'
gem 'activerecord-import' # Use this more! In particular for arms/calendar creation
gem 'activeresource'
gem 'activerecord-session_store' # Required: DB-backed sessions (config/initializers/session_store.rb)
gem 'acts_as_list', git: 'https://github.com/swanandp/acts_as_list.git'
# gem 'acts-as-taggable-on', git: 'https://github.com/Fodoj/acts-as-taggable-on.git', branch: 'rails-5.2' # Consider updating to https://github.com/mbleigh/acts-as-taggable-on
gem 'acts-as-taggable-on'#Had to be upgraded/changed, needs testing/work
gem 'audited', '~> 5.0'
gem 'babel-transpiler'
gem 'bootsnap', require: false
gem 'bootstrap-sass', '3.4.1' # Catalog Manager (BS3) only – remove when CM migrates to BS4/5
gem 'bootstrap3-datetimepicker-rails' # Catalog Manager (BS3) only – remove when CM migrates to BS4/5
gem 'bootstrap-toggle-rails' # Catalog Manager (BS3) only – remove when CM migrates to BS4/5
gem 'capistrano', '~> 3.17'
gem 'capistrano-bundler', require: false
gem 'capistrano-rvm', require: false
gem 'capistrano-rails', require: false
gem 'capistrano-passenger', require: false
gem 'capistrano3-delayed-job', '~> 1.7'
gem 'capistrano-yarn'
gem 'caxlsx'
gem 'caxlsx_rails'
gem 'coffee-rails'
gem 'country_select'
gem 'curb', '~> 1.0.5'
gem 'dartsass-rails'
gem 'deep_cloneable', '~> 3.2.0'
gem 'delayed_job_active_record'
gem 'delayed_job'
gem 'devise', '~> 5.0'
gem "doorkeeper", ">= 5.9.1" # OAuth application API authentication
gem 'dotenv-rails'
gem 'execjs'
gem 'exception_notification'
gem 'font-awesome-sass'
gem 'filterrific', '~> 5.2.6'
gem "grape", "~> 3.1"
gem 'grape-entity', '~> 0.10.2'
gem 'grouped_validations', :git => 'https://github.com/jleonardw9/grouped_validations.git', branch: 'master'
gem 'haml'
gem 'hashie-forbidden_attributes' # Needed: Grape build_with :hashie_mash (app/api/v1/base.rb)
gem 'httparty', '~> 0.24.0'
gem 'i18n-js'
gem 'icalendar', '2.12.2'
gem 'icalendar-recurrence'
gem 'iconv'
gem 'jquery-rails' # Assets shadowed by app/assets/javascripts/jquery*.js; also a dep of twitter-typeahead-rails
gem 'jbuilder', '~> 2.13'
gem 'json', "< 3.0"
gem 'letter_opener'
gem 'microsoft_teams_incoming_webhook_ruby'
gem 'mysql2', '0.5.6'
gem 'nokogiri', '>=1.19.4'
gem 'nprogress-rails' # Catalog Manager (BS3) only – remove when CM migrates to BS4/5
gem 'net-ldap', '~> 0.17.1'
gem "observer"
gem 'omniauth'
gem 'omniauth-cas'
gem 'omniauth-shibboleth'
gem 'omniauth-rails_csrf_protection'
gem 'pdfkit'  # Check usage
gem 'prawn-table'
gem 'prawn' # Needed: PDF generation (see app/lib/cost_analysis/generator.rb and dashboard protocols_controller.rb where Prawn::Document is used)
gem 'premailer-rails'
gem 'rack', '~> 3.1'
gem 'rack-mini-profiler', require: false
gem "rails", "~> 8.1.4"
gem "sprockets-rails"
gem 'rest-client' # Consider replacing usage with httparty
gem 'request_store'
gem 'rubyzip', '~> 3.4'
gem 'savon', '~> 2.17.2'
gem 'slack-notifier'
gem 'terser'
gem 'twitter-typeahead-rails' # Catalog Manager (BS3) only – remove when CM migrates to BS4/5
gem 'wash_out'
gem 'whenever', require: false
gem 'will_paginate'
gem 'will_paginate-bootstrap4'
gem 'x-editable-rails'
gem 'msteams-ruby-client'
gem 'wkhtmltopdf-binary'
gem 'webrick'

group :production do
end

group :development, :test, :profile do
  gem 'puma', '>= 7.2.1'
  gem 'equivalent-xml' # Needed: be_equivalent_to matcher in spec/extensions/epic_interface_spec.rb
  gem 'faker'
  gem 'launchy' # Needed: `sos` helper (spec/support/save_and_open_screenshot.rb) opens screenshots
  gem 'timecop'
  gem 'progress_bar'
  gem 'bcrypt_pbkdf'
  gem 'ed25519'
end

group :development, :test do
  gem 'byebug'
  gem 'email_spec' # Needed: mailer spec matchers (spec/mailers/*, spec/support/emails/*)
  gem 'factory_bot_rails'
  gem 'pdf-inspector', require: false
  gem 'pry'
  gem 'rails-controller-testing', require: false # Consider removing and cleaning up controller specs
  gem 'rails-erd' # Check usage
  gem 'rspec-collection_matchers'
  gem 'rspec-html-matchers' # Consider removing and using `have_selector` matchers
  gem 'rspec-rails', '~> 8.0'
  gem 'selenium-webdriver', '~> 4.49.0'
  gem 'shoulda-callback-matchers'
  gem 'shoulda-matchers', require: false
  gem 'simplecov', require: false # Required in spec/spec_helper.rb and started in spec/support/simple_cov.rb
  gem 'site_prism'
  gem 'webmock'
  gem 'rspec-retry'
end

group :development do
  gem 'highline' # used by app/lib/initial_cm_creation.rb (rails r initial_cm_creation)
  gem 'spring'
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
  gem 'ruby-prof', '~> 1.7.1' # Check usage
end
