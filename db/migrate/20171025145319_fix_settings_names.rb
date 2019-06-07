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

class FixSettingsNames < ActiveRecord::Migration[5.1]
  def change
    #Update key names for settings, to match former application.yml names (for initial import), and modify parent key names to match.
    if setting = Setting.find_by_key("use_research_master")
      setting.key = "research_master_enabled"
      setting.save(validate: false)
    end
    if setting = Setting.find_by_key("research_master_api_url")
      setting.key = "research_master_api"
      setting.parent_key = "research_master_enabled"
      setting.save(validate: false)
    end
    if setting = Setting.find_by_key("research_master_api_token")
      setting.key = "rmid_api_token"
      setting.parent_key = "research_master_enabled"
      setting.save(validate: false)
    end
    if setting = Setting.find_by_key("use_system_satisfaction_survey")
      setting.key = "system_satisfaction_survey"
      setting.save(validate: false)
    end
    if setting = Setting.find_by_key("redcap_api_token")
      setting.key = "redcap_token"
      setting.save(validate: false)
    end
    if setting = Setting.find_by_key("epic_rights_mail_to")
      setting.key = "approve_epic_rights_mail_to"
      setting.save(validate: false)
    end

    #Update parent id's for settings not themselves having key name changed.
    if (setting = Setting.find_by_key("research_master_link")).parent_key == "use_research_master"
      setting.parent_key = "research_master_enabled"
      setting.save(validate: false)
    end
    if (setting = Setting.find_by_key("system_satisfaction_survey_cc")).parent_key == "use_system_satisfaction_survey"
      setting.parent_key = "system_satisfaction_survey"
      setting.save(validate: false)
    end
  end
end
