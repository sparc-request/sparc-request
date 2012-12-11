set :rvm_ruby_string, "1.9.3@sparc-rails"
set :rvm_type, :system
set :rvm_install_with_sudo, true

set :default_environment, { 'BUNDLE_GEMFILE' => "DeployGemfile" }

set :bundle_gemfile, "DeployGemfile"
set :bundle_without, [:development, :test]

set :application, "sparc-rails"
set :repository,  "git@github.com:HSSC/sparc-rails.git"
set :deploy_root, "/var/www/rails"

set :scm, :git
set :deploy_via, :remote_cache
set :keep_releases, 5
set :user, "capistrano"
set :use_sudo, false
ssh_options[:forward_agent] = true

set :stages, %w(testing staging production)
set :default_stage, "testing"

#before "deploy:setup", "rvm:install_rvm"
#before "deploy:setup", "rvm:install_ruby"

after "deploy:update_code", "db:symlink"

namespace :deploy do
  desc "restart app"
  task :restart, :roles => :app do
    run "touch #{current_path}/tmp/restart.txt"
  end

  desc "starts the app"
  task :start, :roles => :app do
    run "touch #{current_path}/tmp/restart.txt"
  end

  desc "does nothing"
  task :stop, :roles => :app do
    #nothing
  end
end

namespace :db do
  task :symlink do
    run "ln -nfs #{shared_path}/config/database.yml #{release_path}/config/database.yml"
    run "ln -nfs #{shared_path}/config/setup_load_paths.rb #{release_path}/config/setup_load_paths.rb"

    #symlink other apps so that sparc-rails can run as root
    run "ln -nfs /var/www/rails/catalog_manager/current/public #{release_path}/public/catalog_manager"
    run "ln -nfs /var/www/rails/portal/current/public #{release_path}/public/portal"

    #symlinked document folders
    run "ln -nfs #{shared_path}/system /var/www/rails/portal/current/public/system"
  end

  desc "seed the database for the rails environment"
  task :seed do
    puts "seeding the #{rails_env} database"
    run "cd #{current_path} ; rake db:seed RAILS_ENV=#{rails_env}"
  end
end

require 'capistrano/ext/multistage'
require 'bundler/capistrano'
require 'rvm/capistrano'

