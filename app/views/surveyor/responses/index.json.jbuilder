if @type == 'Form'
  accessible_surveys = Form.for_admin_users(current_user)
else
  accessible_surveys = SystemSurvey.for(current_user)
end

json.(@responses) do |response|
  json.srid             protocol_link(response)
  json.short_title      response.try(:respondable).try(:protocol).try(:short_title) || 'N/A'
  json.primary_pi       response.try(:respondable).try(:protocol).try(:primary_pi).try(:full_name) || 'N/A'
  json.title            response.survey.full_title
  json.by               response.identity.try(:full_name) || 'N/A'
  json.complete         complete_display(response)
  json.completion_date  response.completed? ? format_date(response.created_at, html: true) : ""
  json.survey_sent_date format_date(response.updated_at, html: true)
  json.actions          response_options(response, accessible_surveys)
end
