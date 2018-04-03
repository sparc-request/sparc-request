json.(@responses) do |response|
  json.srid             response.try(:respondable).try(:display_id) || response.try(:respondable).try(:protocol_id) || 'N/A'
  json.short_title      response.try(:respondable).try(:protocol).try(:short_title) || 'N/A'
  json.primary_pi       response.try(:respondable).try(:protocol).try(:primary_principal_investigator).try(:full_name) || 'N/A'
  json.title            response.survey.full_title
  json.complete         complete_display(response)
  json.completion_date  format_date(response.created_at)
  json.actions          response_options(response)
end
