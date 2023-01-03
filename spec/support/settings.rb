# Copyright © 2011-2022 MUSC Foundation for Research Development~
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

def populate_settings_before_suite
  @settings_populated ||= false

  # Don't re-run settings population
  unless @settings_populated
    Setting.auditing_enabled = false
    SettingsPopulator.new().populate

    Setting.find_by_key("use_epic").update_attribute(:value, true)
    Setting.find_by_key("use_confidentiality_questions").update_attribute(:value, true)
    Setting.find_by_key("use_ldap").update_attribute(:value, false)
    Setting.find_by_key("use_funding_module").update_attribute(:value, true)
    Setting.find_by_key("suppress_ldap_for_user_search").update_attribute(:value, true)
    Setting.find_by_key("ldap_auth_username").update_attribute(:value, nil)
    Setting.find_by_key("ldap_auth_password").update_attribute(:value, nil)
    Setting.find_by_key("ldap_filter").update_attribute(:value, nil)

    load File.expand_path("../../../app/lib/directory.rb", __FILE__)

    @settings_populated = true
  end
end

def stub_config(key, value)
  unless setting = Setting.find_by_key(key)
    # Scenario: The specs are run such that a stub_config is called before
    # a test causes there to be no Settings yet. before :suite doesn't work
    populate_settings_before_suite
    setting = Setting.find_by_key(key)
  end

  default_value = setting.value

  before :each do
    setting.update_attribute(:value, value)
  end

  after :each do
    setting.update_attribute(:value, default_value)
  end
end

RSpec.configure do |config|
  config.before :all do
    populate_settings_before_suite
  end

  config.before :each do
    # This sometimes triggers a failure because of missing settings depending on
    # the order that specs are run. This method wastes processing during the suite
    # so let's stub it
    allow_any_instance_of(Identity).to receive(:send_admin_mail).and_return(true)

    # Cache settings for slight efficiency boost during tests
    Setting.preload_values
  end
end
