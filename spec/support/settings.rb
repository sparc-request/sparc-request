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

def populate_settings_before_suite
  SettingsPopulator.new().populate

  Setting.find_by_key("use_epic").update_attribute(:value, true)
  Setting.find_by_key("use_ldap").update_attribute(:value, false)
  Setting.find_by_key("use_funding_module").update_attribute(:value, true)
  Setting.find_by_key("suppress_ldap_for_user_search").update_attribute(:value, true)
  Setting.find_by_key("ldap_auth_username").update_attribute(:value, nil)
  Setting.find_by_key("ldap_auth_password").update_attribute(:value, nil)
  Setting.find_by_key("ldap_filter").update_attribute(:value, nil)

  load File.expand_path("../../../app/lib/directory.rb", __FILE__)
end

def stub_config(key, value)
  setting = Setting.find_by_key(key)
  default_value = setting.value

  before :each do
    setting.update_attribute(:value, value)
  end

  after :each do
    setting.update_attribute(:value, default_value)
  end
end

RSpec.configure do |config|
  config.before :each do
    Setting.preload_values
  end
end
