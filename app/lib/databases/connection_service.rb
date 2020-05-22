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

#frozen_string_literal: true

module Databases
  class ConnectionService
    attr_accessor :database, :university_key

    def initialize(university)
      @university_key = university.key
      @database       = university.database
    end

    def call
      setup_database_connection unless shard_setup?
    end

    private

    def shard_setup?
      environment_config = Octopus.config[Rails.env.to_sym]
      environment_config.present? && environment_config.key?(university_key)
    end

    def setup_database_connection
      shards = Octopus.config[Rails.env].try(:[], 'shards') || {}

      Octopus.setup do |config|
        config.environments = [Rails.env.to_sym]
        config.shards = {
          'shards' => shards.merge({
            university_key.downcase.to_sym => university_database_configs
          })
        }
      end
    rescue StandardError => exception
      exception.message
    end

    def university_database_configs
      {
        adapter:  'mysql2',
        database: database.name,
        username: database.username,
        password: database.password,
        host:     database.host,
        encoding: 'utf8',
        variables: {
          sql_mode: "TRADITIONAL"
        }
      }
    end
  end
end
