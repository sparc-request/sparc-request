require 'date'

set :default_environment, { 'BUNDLE_GEMFILE' => "DeployGemfile" }

set :bundle_gemfile, "DeployGemfile"
set :bundle_without, [:development, :test]

set :application, "sparc-rails"
set :repository,  "git@github.com:HSSC/sparc-rails.git"
set :deploy_root, "/var/www/rails"
set :days_to_keep_backups 30

set :scm, :git
set :deploy_via, :remote_cache
set :keep_releases, 5
set :user, "capistrano"
set :use_sudo, false
ssh_options[:forward_agent] = true

set :stages, %w(testing demo staging production)
set :default_stage, "testing"

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
    run "ln -nfs #{shared_path}/config/application.yml #{release_path}/config/application.yml"
    run "ln -nfs #{shared_path}/config/ldap.yml #{release_path}/config/ldap.yml"
  end

  desc "seed the database for the rails environment"
  task :seed do
    puts "seeding the #{rails_env} database"
    run "cd #{current_path} ; rake db:seed RAILS_ENV=#{rails_env}"
  end
end

namespace :mysql do
  desc "performs a backup (using mysqldump) in app shared dir"
  task :backup, :roles => :db, :only => { :primary => true } do
    filename = "#{application}.db_backup.#{Time.now.to_f}.sql.bz2"
    filepath = "#{shared_path}/database_backups/#{filename}"
    text = capture "cat #{shared_path}/config/database.yml"
    yaml = YAML::load(text)

    run "mkdir -p #{shared_path}/database_backups"

    on_rollback { run "rm #{filepath}" }
    run "mysqldump -u #{yaml[rails_env]['username']} -p #{yaml[rails_env]['database']} | bzip2 -c > #{filepath}" do |ch, stream, out|
      ch.send_data "#{yaml[rails_env]['password']}\n" if out =~ /^Enter password:/
    end
    
  end

  desc "removes all database backups that are older than days_to_keep_db_backups"
  task :cleanup_backups, :roles => :db, :only => { :primary => true } do
    backup_dir = "#{shared_path}/database_backups/"
    backups = Dir.entries(backup_dir).find_all {|file_name| file_name =~ /.*\.bz2/}
    backup_files = backups.map {|file_name| backup_dir + file_name}
    old_backup_date = Date.today - days_to_keep_backups
    backups_to_delete = backup_files.find_all {|file| File.mtime(file).to_date < old_backup_date}
    File.delete(backups_to_delete)
  end
end

before "deploy:migrate", 'mysql:backup' 
before "deploy", 'mysql:backup' 
after "mysql:backup", "mysql:cleanup_backups"

require 'capistrano/ext/multistage'
require 'bundler/capistrano'
