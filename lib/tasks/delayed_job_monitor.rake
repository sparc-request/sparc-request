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

require 'open3'
require 'slack-notifier'
require 'microsoft_teams_incoming_webhook_ruby'

task delayed_job_monitor: :environment do
  dj_slack_webhook = Setting.get_value("delayed_job_monitor_slack_webhook")
  dj_teams_webhook = Setting.get_value("delayed_job_monitor_teams_webhook")
  workers = ENV.fetch("DJ_WORKERS", 4).to_i

  stdout, stderr, status = Open3.capture3("RAILS_ENV=#{Rails.env} bundle exec bin/delayed_job -n #{workers} status")
  prev_status = stderr

  if stderr =~ /no instances running/
    message = ""
    if dj_slack_webhook.present? || dj_teams_webhook.present?
      message += "```\n[SPARCRequest][#{Rails.env}]\n"
      message += prev_status.split("\n").last + "\n" # makes sure we only get the last message and not the warnings, this may go away on production

      message += "delayed_job: attempting restart\n"
    end

    stdout, stderr, status = Open3.capture3("RAILS_ENV=#{Rails.env} bundle exec bin/delayed_job -n #{workers} restart")
    curr_status = stdout

    if dj_slack_webhook.present? || dj_teams_webhook.present?
      message += curr_status + "```"
    end

    if dj_slack_webhook.present?
      slack_notifier = Slack::Notifier.new(dj_slack_webhook)

      slack_notifier.ping(message)
    end

    if dj_teams_webhook.present?
      teams_message = MicrosoftTeamsIncomingWebhookRuby::Message.new do |tm|
        tm.url = dj_teams_webhook
        tm.text = message
      end

      teams_message.send
    end
  end
end
