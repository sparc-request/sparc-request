class AddTeamsWebhookSetting < ActiveRecord::Migration[7.0]
  def change
    Setting.create(key: "delayed_job_monitor_teams_webhook", data_type: "string", friendly_name: "Post to MS Teams when delayed job monitor rake task runs", description: "If this is set to a MS Teams webhook url, the rake task will post delayed job status updates every hour or whatever the current config/schedule.rb is.")
  end
end
