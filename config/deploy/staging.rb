set :deploy_to, "#{deploy_root}/#{application}"
set :rails_env, "staging"
set :domain, "obis-sparc-stg.mdc.musc.edu"
set :branch, "staging"

role :web, domain
role :app, domain, :primary => true
role :db, domain, :primary => true
