json.(@surveys, @roles) do |survey|
  json.surveyable     survey.surveyable.try(:organization_hierarchy, true, false, true) || t(:surveyor)[:surveys][:form][:placeholders][:survey][:surveyable]
  json.title               survey.title
  json.access_code         survey.access_code
  json.version             survey.version
  json.active              survey_active_display(survey)
  json.notify_roles        survey_notify_roles_display(survey, @roles)
  json.notify_requester?   survey_notify_requester_display(survey)
  json.actions             survey_options(survey)
end
