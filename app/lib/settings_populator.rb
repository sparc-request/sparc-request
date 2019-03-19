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

class SettingsPopulator
  include DataTypeValidator

  def initialize
    load_data_and_config
  end

  def populate
    ActiveRecord::Base.transaction do
      @defaults.each do |hash|
        if Setting.exists?(key: hash['key'])
          Setting.find_by_key(hash['key']).update_attributes(hash.without('key', 'value'))
        else
          setting = Setting.create(
            key:            hash['key'],
            value:          @stored[hash['key']].present? ? @stored[hash['key']] : hash['value'],
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
    end
  end

  private

  def load_data_and_config
    @defaults = JSON.parse(File.read(Rails.root.join('config', 'defaults.json')))
    @stored   = {}

    if File.exists? Rails.root.join('config', 'application.yml')
      @stored.merge!(YAML.load_file(Rails.root.join('config', 'application.yml'))[Rails.env])
    end

    if File.exists? Rails.root.join('config', 'epic.yml')
      @stored.merge!(YAML.load_file(Rails.root.join('config', 'epic.yml'))[Rails.env])
    end

    if File.exists? Rails.root.join('config', 'ldap.yml')
      @stored.merge!(YAML.load_file(Rails.root.join('config', 'ldap.yml'))[Rails.env])
    end
  end
end
