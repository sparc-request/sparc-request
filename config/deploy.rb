# config valid only for current version of Capistrano
lock "3.8.0"

set :application, "sparc_rails"
set :repo_url, "git@github.com:bmic-development/sparc-request.git"
set :scm, :git
set :user, 'capistrano'
set :use_sudo, false

set :stages, %w(testing demo demo2 staging production)
set :default_stage, 'testing'

set :whenever_identifier, ->{ "#{fetch(:application)}_#{fetch(:stage)}" }

set :linked_files, fetch(:linked_files, []).push('config/database.yml', 'config/secrets.yml', '.ruby-version', '.ruby-gemset')

set :linked_dirs, fetch(:linked_dirs, []).push('log', 'tmp/pids', 'tmp/cache', 'tmp/sockets')

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
end

namespace :db do
  task :symlink do
    run "ln -nfs #{shared_path}/config/database.yml #{release_path}/config/database.yml"
    run "ln -nfs #{shared_path}/config/setup_load_paths.rb #{release_path}/config/setup_load_paths.rb"
    run "ln -nfs #{shared_path}/config/application.yml #{release_path}/config/application.yml"
    run "ln -nfs #{shared_path}/config/ldap.yml #{release_path}/config/ldap.yml"
    run "ln -nfs #{shared_path}/config/epic.yml #{release_path}/config/epic.yml"
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
    if ENV['perform_db_backups']
      filename = "#{application}.db_backup.#{Time.now.to_f}.sql.bz2"
      filepath = "#{shared_path}/database_backups/#{filename}"
      text = capture "cat #{shared_path}/config/database.yml"
      yaml = YAML::load(text)

      run "mkdir -p #{shared_path}/database_backups"

      on_rollback { run "rm #{filepath}" }
      run "mysqldump -u #{yaml[rails_env]['username']} -p #{yaml[rails_env]['database']} | bzip2 -c > #{filepath}" do |ch, stream, out|
        ch.send_data "#{yaml[rails_env]['password']}\n" if out =~ /^Enter password:/
      end
    else
      puts "    *************************"
      puts "    Skipping Database Backups"
      puts "    *************************"
    end
  end

  desc "removes all database backups that are older than days_to_keep_backups"
  task :cleanup_backups, :roles => :db, :only => { :primary => true } do
    if ENV['perform_db_backups']
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
    else
      puts "    *************************"
      puts "    Skipping Database Backups"
      puts "    *************************"
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

namespace :delayed_job do
  desc "Start delayed_job process"
  task :start, :roles => :app do
    run "cd #{current_path} && RAILS_ENV=#{rails_env} bundle exec script/delayed_job start"
  end

  desc "Stop delayed_job process"
  task :stop, :roles => :app do
    run "cd #{current_path} && RAILS_ENV=#{rails_env} bundle exec script/delayed_job stop"
  end

  desc "Restart delayed_job process"
  task :restart, :roles => :app do
    run "cd #{current_path} && RAILS_ENV=#{rails_env} bundle exec script/delayed_job restart"
  end
end

after "deploy:start", "delayed_job:start"
after "deploy:stop", "delayed_job:stop"
after "deploy:restart", "delayed_job:restart"

before "deploy:migrate", 'mysql:backup'
before "deploy", 'mysql:backup'
after "mysql:backup", "mysql:cleanup_backups"

