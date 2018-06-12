# Copyright © 2011-2018 MUSC Foundation for Research Development
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

class DefaultSettingsPopulator
  include DataTypeValidator

  def initialize()
    @records = JSON.parse(File.read('config/defaults.json'))
    @application_config =
      if File.exists? Rails.root.join('config', 'application.yml')
        YAML.load_file(Rails.root.join('config', 'application.yml'))[Rails.env]
      else
        {}
      end
  end

  def populate
    ActiveRecord::Base.transaction do
      @records.each do |hash|
        setting = Setting.create(
          key:            hash['key'],
          value:          @application_config[hash['key']] || hash['value'],
          data_type:      get_type(hash['value']),
          friendly_name:  hash['friendly_name'],
          description:    hash['description'],
          group:          hash['group'],
          version:        hash['version'],
        )

        setting.parent_key    = hash['parent_key']
        setting.parent_value  = hash['parent_value']
        setting.save(validate: false)
      end
    end
    Rake::Task["data:import_epic_yml"].invoke
    Rake::Task["data:import_ldap_yml"].invoke
  end
end
