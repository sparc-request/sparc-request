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

task delayed_job_monitor: :environment do
  # https://hooks.slack.com/services/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
  delayed_job_webhook = Setting.get_value("delayed_job_monitor_slack_webhook")

  if delayed_job_webhook.present?
    notifier = Slack::Notifier.new(delayed_job_webhook)
  end

  stdout, stderr, status = Open3.capture3("RAILS_ENV=#{Rails.env} bundle exec bin/delayed_job status")
  prev_status = stderr

  if stderr =~ /delayed_job: no instances running/
    message = ""
    if delayed_job_webhook.present?
      message += "```[SPARCRequest][#{Rails.env}]\n"
      message += prev_status

      message += "delayed_job: attempting restart\n"
    end

    stdout, stderr, status = Open3.capture3("RAILS_ENV=#{Rails.env} bundle exec bin/delayed_job start")
    curr_status = stdout

    if delayed_job_webhook.present?
      message += curr_status + "```"
      notifier.ping(message)
    end
  end
end
