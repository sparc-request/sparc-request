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

class FixEpicAndLdapSettings < ActiveRecord::Migration[5.2]
  def up
    # Update keys
    if Setting.where(key: 'endpoint').any?
      Setting.find_by_key('endpoint').update_attribute(:key, 'epic_endpoint')
    end

    if Setting.where(key: 'namespace').any?
      Setting.find_by_key('namespace').update_attribute(:key, 'epic_namespace')
    end

    if Setting.where(key: 'study_root').any?
      Setting.find_by_key('study_root').update_attribute(:key, 'epic_study_root')
    end

    if Setting.where(key: 'test_mode').any?
      Setting.find_by_key('test_mode').update_attribute(:key, 'epic_test_mode')
    end

    if Setting.where(key: 'wsdl').any?
      Setting.find_by_key('wsdl').update_attribute(:key, 'epic_wsdl')
    end

    # Refresh other attributes (friendly name, description, group, etc)
    SettingsPopulator.new().populate
  end

  def down
    if Setting.where(key: 'epic_endpoint').any?
      Setting.find_by_key('epic_endpoint').update_attribute(:key, 'endpoint')
    end

    if Setting.where(key: 'epic_namespace').any?
      Setting.find_by_key('epic_namespace').update_attribute(:key, 'namespace')
    end

    if Setting.where(key: 'epic_study_root').any?
      Setting.find_by_key('epic_study_root').update_attribute(:key, 'study_root')
    end

    if Setting.where(key: 'epic_test_mode').any?
      Setting.find_by_key('epic_test_mode').update_attribute(:key, 'test_mode')
    end

    if Setting.where(key: 'epic_wsdl').any?
      Setting.find_by_key('epic_wsdl').update_attribute(:key, 'wsdl')
    end
  end
end
