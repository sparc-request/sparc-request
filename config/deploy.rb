set :default_environment, { 'BUNDLE_GEMFILE' => "DeployGemfile" }

set :bundle_gemfile, "DeployGemfile"
set :bundle_without, [:development, :test]

set :application, "sparc-rails"
set :repository,  "git@github.com:HSSC/sparc-rails.git"
set :deploy_root, "/var/www/rails"
set :days_to_keep_backups, 30

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

  desc "removes all database backups that are older than days_to_keep_backups"
  task :cleanup_backups, :roles => :db, :only => { :primary => true } do
    backup_dir = "#{shared_path}/database_backups"
    # Gets the output of ls as a string and splits on new lines and
    # selects the bziped files.
    backups = capture("ls #{backup_dir}").split("\n").find_all {|file_name| file_name =~ /.*\.bz2/}
    old_backup_date = (Time.now.to_date - days_to_keep_backups).to_time
    backups.each do |file_name|
      # Gets the float epoch timestamp out of the file name
      timestamp = file_name.match(/\.((\d*)\.(\d*))/)[1]
      backup_time = Time.at(timestamp.to_f)
      if backup_time < old_backup_date
        run "rm #{backup_dir}/#{file_name}"
      end
    end
  end
end

namespace :survey do
  desc "load/update a survey"
  task :parse do
    if ENV['FILE']
      transaction do
        run "cd #{current_path} && rake surveyor FILE=#{ENV['FILE']} RAILS_ENV=#{rails_env}"
      end
    else
      raise "FILE must be specified (eg. cap survey:parse FILE=surveys/your_survey.rb)"
    end
  end
end

before "deploy:migrate", 'mysql:backup' 
before "deploy", 'mysql:backup' 
after "mysql:backup", "mysql:cleanup_backups"

require 'capistrano/ext/multistage'
require 'bundler/capistrano'
