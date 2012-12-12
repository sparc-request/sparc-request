source 'https://rubygems.org'

gem 'rails', '3.2.8'

# Bundle edge Rails instead:
# gem 'rails', :git => 'git://github.com/rails/rails.git'

gem 'mysql2'
gem 'haml'
gem 'sass'

group :development, :test, :profile do
  gem 'sqlite3'
  gem 'rubyception'
  gem 'rspec-rails'
  gem 'launchy'
  gem 'capybara'
  gem 'database_cleaner'
  gem 'factory_girl'
  gem 'faker'
  gem 'timecop'
  gem 'debugger'

end

# these are needed for the import script
group :import do
  gem 'alfresco_handler', :path => '../alfresco_handler'
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
end

gem 'jquery-rails'
gem 'cache_digests'
gem 'dynamic_form'

#gem 'obis-bridge', :path => '../obis-bridge' this now lives within the application
# yanked from obis-bridge
gem 'json'
gem 'sinatra'
gem 'grouped_validations'
gem 'obis-net-ldap'
gem 'paperclip'
gem 'acts_as_list'
gem "paper_trail", "~> 2"
gem 'devise'
gem 'omniauth'
gem 'omniauth-shibboleth'
# end obis-bridge gems

gem 'will_paginate'

# requirements for excel export
gem 'axlsx_rails'

# Deploy with Capistrano
gem 'capistrano'
gem 'capistrano-ext'
gem 'rvm-capistrano'

group :profile do
  gem 'ruby-prof'
end
