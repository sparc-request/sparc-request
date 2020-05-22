class AddSurveyCompletionAlertsToOrganizations < ActiveRecord::Migration[5.2]
  using_group(:shards)

  def change
    add_column :organizations, :survey_completion_alerts, :boolean, default: false
  end
end
