# Copyright © 2011-2019 MUSC Foundation for Research Development~
# All rights reserved.~

# Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:~

# 1. Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.~

# 2. Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following~
# disclaimer in the documentation and/or other materials provided with the distribution.~

# 3. Neither the name of the copyright holder nor the names of its contributors may be used to endorse or promote products~
# derived from this software without specific prior written permission.~

# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING,~
# BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT~
# SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL~
# DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS~
# INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR~
# TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.~

# config valid only for current version of Capistrano
lock "3.11.2"

set :application, "sparc_rails"
set :repo_url, "git@github.com:bmic-development/sparc-request.git"
set :user, 'capistrano'
set :use_sudo, false

set :stages, %w(testing demo demo2 staging production)
set :default_stage, 'testing'

set :whenever_identifier, ->{ "#{fetch(:application)}_#{fetch(:stage)}" }

set :linked_files, fetch(:linked_files, []).push('config/database.yml', 'config/fulfillment_db.yml', 'config/shards.yml', 'config/setup_load_paths.rb', 'config/application.yml', 'config/ldap.yml', 'config/epic.yml', '.env', 'app/views/shared/_analytics.html.haml')

set :linked_dirs, fetch(:linked_dirs, []).push('log', 'tmp/pids', 'tmp/cache', 'tmp/sockets', 'public/system', 'public/assets', 'public/images')

namespace :deploy do
  desc 'Runs rake db:migrate if migrations are set'
  task :migrate_shards => [:set_rails_env] do
    on fetch(:migration_servers) do
      conditionally_migrate = fetch(:conditionally_migrate)
      info '[deploy:migrate_shards] Checking changes in db' if conditionally_migrate
      if conditionally_migrate && test(:diff, "-qr #{release_path}/db #{current_path}/db")
        info '[deploy:migrate_shards] Skip `deploy:migrate_shards` (nothing changed in db)'
      else
        info '[deploy:migrate_shards] Run `rake shards:migrate`'
        # NOTE: We access instance variable since the accessor was only added recently. Once capistrano-rails depends on rake 11+, we can revert the following line
        invoke :'deploy:migrating_shards' unless Rake::Task[:'deploy:migrating_shards'].instance_variable_get(:@already_invoked)
      end
    end
  end

  desc 'Runs rake shards:migrate'
  task migrating_shards: [:set_rails_env] do
    on fetch(:migration_servers) do
      within release_path do
        with rails_env: fetch(:rails_env) do
          execute :rake, 'shards:migrate'
        end
      end
    end
  end

  desc 'Runs rake data:import_settings'
  task import_settings: [:set_rails_env] do
    on fetch(:migration_servers) do
      within release_path do
        with rails_env: fetch(:rails_env) do
          execute :rake, 'data:import_settings'
        end
      end
    end
  end
end

after 'deploy:updated', 'deploy:migrate_shards'
after "deploy:restart", "delayed_job:restart"
after 'deploy', 'deploy:import_settings'
