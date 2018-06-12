json.(@surveys) do |survey|
  json.surveyable     survey.surveyable.try(:organization_hierarchy, true, false, true) || t(:surveyor)[:surveys][:form][:placeholders][:survey][:surveyable]
  json.title          survey.title
  json.access_code    survey.access_code
  json.version        survey.version
  json.display_order  survey.display_order
  json.active         survey_active_display(survey)
  json.options        survey_options(survey)
end
