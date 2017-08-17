# config valid only for current version of Capistrano
lock "3.8.1"

set :application, "sparc_rails"
set :repo_url, "git@github.com:bmic-development/sparc-request.git"
set :user, 'capistrano'
set :use_sudo, false

set :stages, %w(testing demo demo2 staging production)
set :default_stage, 'testing'

set :whenever_identifier, ->{ "#{fetch(:application)}_#{fetch(:stage)}" }

set :linked_files, fetch(:linked_files, []).push('config/database.yml', 'config/setup_load_paths.rb', 'config/application.yml', 'config/ldap.yml', 'config/epic.yml')

set :linked_dirs, fetch(:linked_dirs, []).push('log', 'tmp/pids', 'tmp/cache', 'tmp/sockets', 'public/system')

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

after "deploy:restart", "delayed_job:restart"
