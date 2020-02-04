# Copyright © 2011-2019 MUSC Foundation for Research Development
# All rights reserved.

# Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:

# 1. Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.
  
# 2. Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following
# disclaimer in the documentation and/or other materials provided with the distribution.

# 3. Neither the name of the copyright holder nor the names of its contributors may be used to endorse or promote products
# derived from this software without specific prior written permission.

# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING,
# BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT
# SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
# DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
# INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR
# TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

# This is a combination of code written for the rails-sharding gem
# https://github.com/hsgubert/rails-sharding/blob/eaaaf96200806bcddbf2070b40f6bec6a845f470/lib/tasks/rails-sharding.rake
#
# and Rails core code from the 6-0 stable branch as of version 6.0.2.1
# https://github.com/rails/rails/blob/6-0-stable/activerecord/lib/active_record/railties/databases.rake

require "active_record"

shards_namespace = namespace :shards do

  # for each of the shards, check that 1) the environment set in the ar_internal_metadata
  # table matches the current rails env and 2) it is not a protected environment
  # (defined in ActiveRecord::Base.protected_environments)
  desc "Checks if the environment is not protected and if the shards match the current environment (options: RAILS_ENV=x SHARD=x)"
  task check_protected_environments: :load_config do
    Octopus.config[Rails.env]['shards'].each do |shard, _|
      next if ENV["SHARD"] && ENV["SHARD"] != shard.to_s
      Octopus.using(shard) do
        ActiveRecord::Tasks::DatabaseTasks.check_protected_environments!
      end
    end
  end

  task load_config: :environment do
    setup_migrations_path()
  end

  desc "Creates database shards (options: RAILS_ENV=x SHARD=x)"
  task create: [:load_config] do
    Octopus.config[Rails.env]['shards'].each do |shard, configuration|
      puts "== Creating shard #{shard}"
      ActiveRecord::Tasks::DatabaseTasks.create(configuration)
    end
  end

  desc "Drops database shards (options: RAILS_ENV=x SHARD=x)"
  task drop: [:load_config, :check_protected_environments] do
    Octopus.config[Rails.env]['shards'].each do |shard, configuration|
      puts "== Dropping shard #{shard}"

      ActiveRecord::Tasks::DatabaseTasks.drop(configuration)
    end
  end

  desc "Migrate the database (options: RAILS_ENV=x, VERSION=x, VERBOSE=false, SCOPE=blog)."
  task migrate: :load_config do
    original_config = ActiveRecord::Base.connection_config
    Octopus.using_group(:shards) do
      ActiveRecord::Tasks::DatabaseTasks.migrate
    end

    shards_namespace["_dump"].invoke
  ensure
    ActiveRecord::Base.establish_connection(original_config)
  end

  # IMPORTANT: This task won't dump the schema if ActiveRecord::Base.dump_schema_after_migration is set to false
  task :_dump do
    if ActiveRecord::Base.dump_schema_after_migration
      case ActiveRecord::Base.schema_format
      when :ruby
        shards_namespace["schema:dump"].invoke
      when :sql
        raise "sql schema dump not supported by shards"
      else
        raise "unknown schema format #{ActiveRecord::Base.schema_format}"
      end
    end
    # Allow this task to be called as many times as required. An example is the
    # migrate:redo task, which calls other two internally that depend on this one.
    shards_namespace["_dump"].reenable
  end

  namespace :migrate do
    desc 'Rollbacks the shards one migration and re migrate up (options: RAILS_ENV=x, VERSION=x, STEP=x, SHARD=x).'
    task redo: :load_config do
      raise "Empty VERSION provided" if ENV["VERSION"] && ENV["VERSION"].empty?

      if ENV["VERSION"]
        shards_namespace["migrate:down"].invoke
        shards_namespace["migrate:up"].invoke
      else
        shards_namespace["rollback"].invoke
        shards_namespace["migrate"].invoke
      end
    end

    # desc 'Resets your shards using your migrations for the current environment'
    task reset: ["shards:drop", "shards:create", "shards:migrate"]

    # desc 'Runs the "up" for a given migration VERSION.'
    task up: :load_config do
      raise "VERSION is required" if !ENV["VERSION"] || ENV["VERSION"].empty?

      ActiveRecord::Tasks::DatabaseTasks.check_target_version

      Octopus.config[Rails.env]['shards'].each do |shard, _|
        next if ENV["SHARD"] && ENV["SHARD"] != shard.to_s
        puts "== Migrating up shard #{shard}"
        Octopus.using(shard) do
          ActiveRecord::Migrator.run(
            :up,
            ActiveRecord::Tasks::DatabaseTasks.target_version
          )
        end
      end

      shards_namespace["_dump"].invoke
    end

    # desc 'Runs the "down" for a given migration VERSION.'
    task down: :load_config do
      raise "VERSION is required" if !ENV["VERSION"] || ENV["VERSION"].empty?

      Octopus.config[Rails.env]['shards'].each do |shard, _|
        next if ENV["SHARD"] && ENV["SHARD"] != shard.to_s
        puts "== Migrating down shard #{shard}"
        Octopus.using(shard) do
          ActiveRecord::Migrator.run(
            :down,
            ActiveRecord::Tasks::DatabaseTasks.target_version
          )
        end
      end

      shards_namespace["_dump"].invoke
    end
  end

  namespace :schema do
    desc "Creates a schema.rb for each shard that is portable against any DB supported by Active Record (options: RAILS_ENV=x, SHARD=x)"
    task dump: :load_config do
      Octopus.config[Rails.env]['shards'].each do |shard, configuration|
        puts "== Dumping schema of #{shard}"

        Octopus.using(shard) do
          ActiveRecord::Tasks::DatabaseTasks.dump_schema(configuration, :ruby, shard)
        end
      end

      shards_namespace["schema:dump"].reenable
    end

    desc "Loads schema.rb file into the shards (options: RAILS_ENV=x, SHARD=x)"
    task load: [:load_config, :check_protected_environments] do
      Octopus.config[Rails.env]['shards'].each do |shard, configuration|
        next if ENV["SHARD"] && ENV["SHARD"] != shard.to_s
        puts "== Loading schema of #{shard}"

        Octopus.using(shard) do
          ActiveRecord::Tasks::DatabaseTasks.load_schema(configuration, :ruby, ENV["SCHEMA"], Rails.env, shard)
        end
      end
    end

    task load_if_ruby: ["shards:create", :environment] do
      shards_namespace["schema:load"].invoke if ActiveRecord::Base.schema_format == :ruby
    end
  end

  desc "Rolls the schema back to the previous version (options: RAILS_ENV=x, STEP=x, SHARD=x)."
  task rollback: :load_config do
    step = ENV["STEP"] ? ENV["STEP"].to_i : 1
    Octopus.using_group(:shards) do
      ActiveRecord::Base.connection.migration_context.rollback(step)
    end

    shards_namespace["_dump"].invoke
  end

  desc "Retrieves the current schema version number"
  task version: :load_config do
    Octopus.config[Rails.env]['shards'].each do |shard, _|
      Octopus.using(shard) do
        puts "Shard #{shard} version: #{ActiveRecord::Base.connection.migration_context.current_version}"
      end
    end
  end


  namespace :test do
    # desc "Recreate the test shards from existent schema files (options: SHARD=x)"
    task load_schema: %w(shards:test:purge) do
      should_reconnect = ActiveRecord::Base.connection_pool.active_connection?

      Octopus.config['test']['shards'].each do |shard, configuration|
        next if ENV["SHARD"] && ENV["SHARD"] != shard.to_s

        puts "== Loading test schema on shard #{shard}"
        filename = filename = ActiveRecord::Tasks::DatabaseTasks.dump_filename(shard, :ruby)

        Rails.env = 'test'

        ActiveRecord::Schema.verbose = false
        ActiveRecord::Base.establish_connection(configuration)
        ActiveRecord::Tasks::DatabaseTasks.load_schema(configuration, :ruby, filename, "test")
      end
    ensure
      if should_reconnect
        ActiveRecord::Base.establish_connection(ActiveRecord::Base.configurations.default_hash(ActiveRecord::Tasks::DatabaseTasks.env))
      end
    end

    # desc 'Load the test schema into the shards (options: SHARD=x)'
    task prepare: :load_config do
      unless Octopus.config['test'].blank?
        shards_namespace["test:load_schema"].invoke
      end
    end

    desc "Empty the test shards (drops all tables) (options: SHARD=x)"
    task :purge do
      Octopus.config['test']['shards'].each do |shard, configuration|
        puts "== Purging test shard #{shard}"

        ActiveRecord::Base.establish_connection(configuration)
        ActiveRecord::Tasks::DatabaseTasks.purge(configuration)
      end
    end
  end

  # Configures path for migrations of this shard group and creates dir if necessary
  # We need this to run migrations (so we can find them)
  # We need this load schemas (se we can build the schema_migrations table)
  def setup_migrations_path
    migrations_dir = File.join(Rails.root, 'db', 'shards_migrate')
    ActiveRecord::Tasks::DatabaseTasks.migrations_paths = [migrations_dir]
    ActiveRecord::Migrator.migrations_paths             = [migrations_dir]
    FileUtils.mkdir_p(migrations_dir)
  end
end

# Bug: Octopus does not handle connection switching when the environment
# changes when running rake shards:test:prepare
#
# See https://github.com/thiagopradi/octopus/issues/426

namespace :octopus do
  task on: :environment do
    ActiveRecord::Base.clear_all_connections!
    Octopus.enable!
  end

  task off: :environment do
    ActiveRecord::Base.clear_all_connections!
    Octopus.disable!
  end
end

Rake::Task['db:create'].enhance(['octopus:off']) do
  Rake::Task['octopus:on'].invoke
end

Rake::Task['db:drop'].enhance(['octopus:off']) do
  Rake::Task['octopus:on'].invoke
end

Rake::Task['shards:test:prepare'].enhance(['octopus:off']) do
  Rake::Task['octopus:on'].invoke
end
