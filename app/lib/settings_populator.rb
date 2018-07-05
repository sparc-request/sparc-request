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

class SettingsPopulator
  include DataTypeValidator

  def initialize()
    @data   = {}
    @config = {}

    load_data_and_config
  end

  def populate
    @data.each do |namespace, settings|
      puts "Populating #{namespace} settings"
      ActiveRecord::Base.transaction do
        settings.each do |hash|
          if Setting.where(key: hash['key']).any?
            Setting.find_by_key(hash['key']).update_attributes(hash.without('key', 'value'))
            puts "- Setting #{hash['key']} already exists... Updated details (this does not change the value!)..."
          else
            setting = Setting.create(
              key:            hash['key'],
              value:          @config[namespace][hash['key']] || hash['value'],
              data_type:      get_type(hash['value']),
              friendly_name:  hash['friendly_name'],
              description:    hash['description'],
              group:          hash['group'],
              version:        hash['version'],
            )

            setting.parent_key    = hash['parent_key']
            setting.parent_value  = hash['parent_value']
            setting.save(validate: false)

            puts "- Added new setting #{hash['key']}..."
          end
        end
      end

      puts "\n\n"
    end
  end

  private

  def load_data_and_config
    Dir.glob('config/settings/*.json').each do |file|
      filename  = file.split('/').last
      namespace = filename.gsub('.json', '')

      @data[namespace]    = JSON.parse(File.read(Rails.root.join('config', 'settings', "#{filename}")))
      @config[namespace]  =
        if File.exists?(Rails.root.join('config', "#{namespace}.yml"))
          YAML.load_file(Rails.root.join('config', "#{namespace}.yml"))[Rails.env]
        else
          {}
        end
    end
  end
end
