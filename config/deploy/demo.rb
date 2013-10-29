set :rvm_ruby_string, "ruby-1.9.3-p286"
set :rvm_type, :system

set :deploy_to, "#{deploy_root}/#{application}"
set :rails_env, "demo"
set :domain, "sparc-demo.musc.edu"
set :branch, "demo"

role :web, domain
role :app, domain, :primary => true
role :db, domain, :primary => true

require 'rvm/capistrano'
