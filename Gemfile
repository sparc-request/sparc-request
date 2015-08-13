source 'https://rubygems.org'

gem 'activerecord-import'
gem 'acts_as_list', '0.1.9'
gem 'acts-as-taggable-on', '~> 2.3.1'
gem 'audited-activerecord', '~> 3.0'
gem 'axlsx'
gem 'axlsx_rails'
gem 'bluecloth'
gem 'cache_digests'
gem 'capistrano'
gem 'capistrano-ext'
gem 'coffee-rails', '~> 3.2.1'
gem 'delayed_job_active_record'
gem 'devise'
gem 'dynamic_form'
gem 'execjs', '1.4.0'
gem 'therubyracer', '0.10.2', :platforms => :ruby
gem 'exception_notification'
gem 'grape', '0.7.0'
gem 'grape-entity', '~> 0.4.4'
gem 'grouped_validations'
gem 'gyoku'
gem 'haml'
gem 'icalendar'
gem 'inflection-js-rails'
gem 'jquery_datepicker'
gem 'jquery-rails', '2.1.3'
gem 'json'
gem 'letter_opener'
gem 'mysql2'
gem 'nested_form'
gem 'nokogiri'
gem 'nori', '~> 2.1.0'
gem 'obis-net-ldap'
gem 'omniauth'
gem 'omniauth-shibboleth'
gem 'paperclip'
gem 'pdfkit'
gem 'prawn', '0.12.0'
gem 'rails', '3.2.21'
gem 'redcarpet'
gem 'rest-client'
gem 'rvm-capistrano', require: false
gem 'sass'
gem 'sass-rails',   '~> 3.2.3'
gem 'savon', '~> 2.2.0'
gem 'simplecov', require: false, group: :test
gem 'sinatra'
gem 'surveyor'
gem 'uglifier', '>= 1.0.3'
gem 'will_paginate'

group :development, :test, :profile do
  gem 'addressable', '~> 2.3.6'
  gem 'bullet'
  gem 'connection_pool'
  gem 'database_cleaner'
  gem 'equivalent-xml'
  gem 'factory_girl'
  gem 'faker'
  gem 'launchy'
  gem 'quiet_assets'
  gem 'rails-erd'
  gem 'rspec'
  gem 'rspec-rails'
  gem 'shoulda-matchers'
  gem 'sqlite3'
  gem 'thin'
  gem 'timecop'
  gem 'turn', require: false
  gem 'watchr'

  # You can put gems in here that you want to use for development but
  # don't want to force on other developers (e.g. rubyception).
  if File.exists?('Gemfile.devel') then
    eval File.read('Gemfile.devel'), nil, 'Gemfile.devel'
  end
end

group :development do
  gem 'highline'
  gem 'rspec-instafail'
  gem 'spring'
  gem 'spring-commands-rspec'
end

group :test do
  gem 'capybara-webkit'
  gem 'shoulda-callback-matchers', '~> 1.1.1'
  gem 'webmock', '~> 1.20.4'
end

group :profile do
  gem 'ruby-prof'
end

group :import do
  gem 'mustache', '0.99.4'
  gem 'progress_bar'
end
