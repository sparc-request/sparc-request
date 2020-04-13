class AddSurveyCompletionAlertsToOrganizations < ActiveRecord::Migration[5.2]
  def change
    add_column :organizations, :survey_completion_alerts, :boolean, default: false
  end
end
