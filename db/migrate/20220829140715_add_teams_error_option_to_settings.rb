class AddTeamsErrorOptionToSettings < ActiveRecord::Migration[5.2]
  def change
    Setting.create(key: "epic_user_api_error_teams_webhook", data_type: "string", friendly_name: "Epic User API Error Teams Webhook.", description: "If this is set to a Teams webhook url, then a teams notification will be posted when a user encountered an error connecting to the Epic user interface.")
  end
end
