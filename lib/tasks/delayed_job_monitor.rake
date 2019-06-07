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
