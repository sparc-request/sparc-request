namespace :capistrano do
  desc 'run some rake db task'
  task :migrate_shards do
    on roles(:app) do
      within "#{current_path}" do
        with rails_env: "#{fetch(:stage)}" do
          execute :rake, "shards:migrate"
        end
      end
    end
  end
end
