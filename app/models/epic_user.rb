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

class EpicUser < ActiveResource::Base
  self.site = Setting.get_value('epic_user_endpoint')

  ##SSL options can be added here:
  # self.ssl_options = {verify_mode: OpenSSL::SSL::VERIFY_NONE}

  #https://c3po-hadoop-s2-v.obis.musc.edu:8484/v1/epicintc/viewuser.json?userid=anc63
  #{"UserID"=>"anc63", "IsExist"=>false}
  #{"UserID"=>"wed3", "UserName"=>"Wei Ding", "IsExist"=>true, "IsActive"=>true, "IsBlocked"=>false, "IsPasswordChangeRequired"=>false}

  def self.confirm_connection
    begin
      epic_url = Setting.find_by_key('epic_user_endpoint').value
      uri = URI.parse(epic_url)
    
      status = Net::HTTP.start(uri.host, uri.port, read_timeout: 5, use_ssl: (uri.scheme == 'https')) do |http|
        request = Net::HTTP::Get.new uri
        response = http.request request
      end

      if status.code == "200"
        true
      else
        false
      end
    rescue => e
      slack_epic_error_webhook = Setting.get_value("epic_user_api_error_slack_webhook")
      teams_epic_error_webhook = Setting.get_value("epic_user_api_error_teams_webhook")

      message = I18n.t('notifier.epic_user_api_slack_error', env: Rails.env)
      message += "\n#{@result}\n"
      message += "\n```#{e.class}\n"
      message += "#{e.message}\n"
      message += "#{e.backtrace[0..5]}```"

      if slack_epic_error_webhook.present?
        notifier = Slack::Notifier.new(slack_epic_error_webhook)
        notifier.ping(message)
      end

      if teams_epic_error_webhook.present?
        notifier = Teams.new(teams_epic_error_webhook)
        notifier.post(message)
      end

      return false
    end
  end

  # force route to use custom collection_name
  def self.collection_name
    @collection_name ||= Setting.get_value('epic_user_collection_name')
  end

  def self.for_identity(identity)
    if confirm_connection
      get(:viewuser, userid: identity.ldap_uid.split('@').first)
    else
      nil
    end
  end

  def self.is_active?(epic_user)
    epic_user && epic_user.key?('IsActive') && epic_user['IsActive']
  end
end
