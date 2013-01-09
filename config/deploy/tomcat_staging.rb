set :deploy_to, "#{deploy_root}/#{application}"
set :rails_env, "staging"
set :domain, "obis-sparc-rails-stg.mdc.musc.edu"
set :branch, "application_merge"

role :web, domain
role :app, domain, :primary => true
role :db, domain, :primary => true
