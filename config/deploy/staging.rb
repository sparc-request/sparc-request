set :rvm_ruby_string, "ruby-1.9.3-p286@sparc"
set :rvm_type, :system
set :rvm_install_with_sudo, true

set :deploy_to, "#{deploy_root}/#{application}"
set :rails_env, "staging"
set :domain, "obis-sparc-stg.mdc.musc.edu"
set :branch, "31014_production_release"

role :web, domain
role :app, domain, :primary => true
role :db, domain, :primary => true

before "deploy:setup", "rvm:install_rvm"
before "deploy:setup", "rvm:install_ruby"

require 'rvm/capistrano'
